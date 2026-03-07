output "table_name" {
  description = "DynamoDB テーブル名"
  value       = aws_dynamodb_table.todos.name
}

output "table_arn" {
  description = "DynamoDB テーブル ARN"
  value       = aws_dynamodb_table.todos.arn
}
