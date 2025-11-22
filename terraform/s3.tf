# --------------------------------------------------------------------------------
# S3バケット作成
# 静的ウェブサイトのコンテンツを保存するバケットを作成します。
# バケット名は全世界で一意である必要があります。
# --------------------------------------------------------------------------------
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

# --------------------------------------------------------------------------------
# パブリックアクセスブロック (完全非公開)
# セキュリティのため、S3バケットへの直接アクセスをすべてブロックします。
# CloudFront経由でのアクセスのみを許可するため、ここはすべて true に設定します。
# --------------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true # 新しいパブリックACLをブロック
  block_public_policy     = true # 新しいパブリックバケットポリシーをブロック
  ignore_public_acls      = true # 既存のパブリックACLを無視
  restrict_public_buckets = true # パブリックバケットポリシーを制限
}

# --------------------------------------------------------------------------------
# バケットポリシー (CloudFrontからのアクセスのみ許可)
# CloudFrontのOAC (Origin Access Control) からのリクエストのみを許可するポリシーを適用します。
# これにより、S3バケットへの直接アクセスを防ぎつつ、CloudFront経由での配信が可能になります。
# --------------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"] # オブジェクトの取得のみを許可
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"] # CloudFrontサービスプリンシパル
    }

    # 特定のCloudFrontディストリビューションからのアクセスのみを許可する条件
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

# --------------------------------------------------------------------------------
# ファイルアップロード
# ローカルのHTMLファイルをS3バケットにアップロードします。
# content_type を指定しないと、ブラウザでダウンロードされてしまう場合があります。
# etag を設定することで、ファイル変更時にのみ再アップロードされるようになります。
# --------------------------------------------------------------------------------
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website_bucket.bucket
  key          = "index.html"
  source       = "../website/index.html" # パスを修正
  content_type = "text/html"
  etag         = filemd5("../website/index.html")
}

resource "aws_s3_object" "error_html" {
  bucket       = aws_s3_bucket.website_bucket.bucket
  key          = "error.html"
  source       = "../website/error.html" # パスを修正
  content_type = "text/html"
  etag         = filemd5("../website/error.html")
}
