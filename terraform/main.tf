# --------------------------------------------------------------------------------
# ルート main.tf
# 各モジュールを呼び出して全リソースを管理します。
# モジュール分割の理由:
#   - 責務ごとに分離 → 変更箇所がわかりやすい
#   - Phase 2 で VPC / RDS モジュールを追加しやすい
#
# ┌─ ユーザー (HTTPS) ──────────────────────────────────────────┐
# │  ↓                                                          │
# │  CloudFront (WAF IP制限) ──→ S3 (index.html, error.html)   │
# │                                                             │
# │  API Gateway ──→ Lambda ──→ DynamoDB                        │
# │  (ブラウザが直接呼び出す。URLは /api-config.json から取得)      │
# └─────────────────────────────────────────────────────────────┘
# --------------------------------------------------------------------------------

# --- S3 モジュール -----------------------------------------------------------
# S3 バケットの作成と静的ファイルのアップロードを担当します。
# バケットポリシー（CloudFront との接続）は下で定義します。
module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

# --- CloudFront モジュール ---------------------------------------------------
# CDN + WAF (IP 制限) を担当します。
# S3 モジュールの出力 (ドメイン名) を受け取ります。
module "cloudfront" {
  source                      = "./modules/cloudfront"
  bucket_name                 = var.bucket_name
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  allowed_ip_v4               = var.allowed_ip_v4
  allowed_ip_v6               = var.allowed_ip_v6
}

# --- S3 バケットポリシー (CloudFront からのみ許可) ----------------------------
# S3 モジュールと CloudFront モジュール両方のアウトプットに依存するため、
# 循環参照を避けるためにルートで定義しています。
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = module.s3.bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudFrontServicePrincipal"
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${module.s3.bucket_arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = module.cloudfront.distribution_arn
        }
      }
    }]
  })
}

# --- DynamoDB モジュール -----------------------------------------------------
# TODO データを永続化するテーブルを作成します。
module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = var.dynamodb_table_name
}

# --- Cognito モジュール ------------------------------------------------------
# 認証基盤として User Pool / App Client / Hosted UI Domain を作成します。
module "cognito" {
  source         = "./modules/cognito"
  user_pool_name = var.cognito_user_pool_name
  domain_prefix  = var.cognito_domain_prefix != "" ? var.cognito_domain_prefix : var.bucket_name
  callback_urls  = var.cognito_callback_urls
  logout_urls    = var.cognito_logout_urls
}

# --- Lambda モジュール -------------------------------------------------------
# 3 つの Lambda 関数 (GET / POST / DELETE) と IAM ロールを担当します。
module "lambda" {
  source              = "./modules/lambda"
  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
}

# --- API Gateway モジュール --------------------------------------------------
# HTTP API のエンドポイントとルーティングを担当します。
module "apigateway" {
  source                        = "./modules/apigateway"
  lambda_get_todos_invoke_arn   = module.lambda.get_todos_invoke_arn
  lambda_post_todo_invoke_arn   = module.lambda.post_todo_invoke_arn
  lambda_delete_todo_invoke_arn = module.lambda.delete_todo_invoke_arn
  lambda_get_todos_arn          = module.lambda.get_todos_arn
  lambda_post_todo_arn          = module.lambda.post_todo_arn
  lambda_delete_todo_arn        = module.lambda.delete_todo_arn
}

# --- API 設定ファイル (フロントエンド用) --------------------------------------
# フロントエンドの JS が /api-config.json を fetch して API URL を取得します。
# これにより HTML を書き換えることなく API URL を注入できます。
resource "aws_s3_object" "api_config" {
  bucket = module.s3.bucket_id
  key    = "api-config.json"
  content = jsonencode({
    apiUrl             = module.apigateway.api_endpoint
    cognitoUserPoolId  = module.cognito.user_pool_id
    cognitoClientId    = module.cognito.user_pool_client_id
    cognitoDomain      = module.cognito.domain
    cognitoHostedUiUrl = module.cognito.hosted_ui_url
  })
  content_type = "application/json"
  etag = md5(jsonencode({
    apiUrl             = module.apigateway.api_endpoint
    cognitoUserPoolId  = module.cognito.user_pool_id
    cognitoClientId    = module.cognito.user_pool_client_id
    cognitoDomain      = module.cognito.domain
    cognitoHostedUiUrl = module.cognito.hosted_ui_url
  }))
}
