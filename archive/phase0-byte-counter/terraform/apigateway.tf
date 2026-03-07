# --------------------------------------------------------------------------------
# API Gateway (HTTP API)
# Lambda関数をWebから呼び出すための窓口を作成します。
# REST APIよりも軽量で安価なHTTP APIを使用します。
# --------------------------------------------------------------------------------

resource "aws_apigatewayv2_api" "http_api" {
  name          = "byte-counter-api"
  protocol_type = "HTTP"
  
  # CORS設定 (ブラウザからのアクセスを許可)
  cors_configuration {
    allow_origins = ["*"] # 本番環境では特定のドメインに絞るべき
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
    max_age       = 300
  }
}

# ステージ (デプロイ環境) の作成
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default" # 自動デプロイが有効なデフォルトステージ
  auto_deploy = true
}

# Lambdaとの統合設定
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  integration_uri    = aws_lambda_function.byte_counter.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# ルーティング設定 (POST /count へのアクセスをLambdaに流す)
resource "aws_apigatewayv2_route" "count_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 権限設定: API GatewayがLambdaを実行できるようにする
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.byte_counter.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*/count"
}
