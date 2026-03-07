# --------------------------------------------------------------------------------
# API Gateway HTTP API
# REST API より軽量・安価な HTTP API を使用します。
# 学習ポイント:
#   - REST API    → 豊富な機能（APIキー認証・使用量プランなど）
#   - HTTP API    → シンプルで安価（Lambda 統合・JWT 認証に最適）
# --------------------------------------------------------------------------------
resource "aws_apigatewayv2_api" "main" {
  name          = "todo-api"
  protocol_type = "HTTP"

  # CORS 設定（ブラウザから直接呼び出すために必要）
  # 本番環境では allow_origins を CloudFront のドメインに絞ること
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type"]
    max_age       = 300
  }
}

# ステージ（デプロイ環境）: auto_deploy = true で変更を即時反映
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

# ============================================================
# GET /todos → Lambda get_todos
# ============================================================
resource "aws_apigatewayv2_integration" "get_todos" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_get_todos_invoke_arn
  integration_method     = "POST" # Lambda 統合は常に POST
  payload_format_version = "2.0"  # 2.0 が推奨（シンプルなイベント形式）
}

resource "aws_apigatewayv2_route" "get_todos" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /todos"
  target    = "integrations/${aws_apigatewayv2_integration.get_todos.id}"
}

# API Gateway に Lambda を実行する権限を付与
resource "aws_lambda_permission" "get_todos" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_get_todos_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/todos"
}

# ============================================================
# POST /todos → Lambda post_todo
# ============================================================
resource "aws_apigatewayv2_integration" "post_todo" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_post_todo_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_todo" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /todos"
  target    = "integrations/${aws_apigatewayv2_integration.post_todo.id}"
}

resource "aws_lambda_permission" "post_todo" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_post_todo_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/todos"
}

# ============================================================
# DELETE /todos/{id} → Lambda delete_todo
# {id} はパスパラメータ（Lambda では event.pathParameters.id で取得）
# ============================================================
resource "aws_apigatewayv2_integration" "delete_todo" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_delete_todo_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "delete_todo" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "DELETE /todos/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_todo.id}"
}

resource "aws_lambda_permission" "delete_todo" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_delete_todo_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/todos/*"
}
