output "api_endpoint" {
  description = "API Gateway のエンドポイント URL（フロントエンドの fetch 先）"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "execution_arn" {
  description = "API Gateway の実行 ARN（Lambda 権限付与に使用）"
  value       = aws_apigatewayv2_api.main.execution_arn
}
