output "get_todos_arn" {
  value = aws_lambda_function.get_todos.arn
}

output "post_todo_arn" {
  value = aws_lambda_function.post_todo.arn
}

output "delete_todo_arn" {
  value = aws_lambda_function.delete_todo.arn
}

# invoke_arn は API Gateway との統合に使用します（arn とは形式が異なります）
output "get_todos_invoke_arn" {
  value = aws_lambda_function.get_todos.invoke_arn
}

output "post_todo_invoke_arn" {
  value = aws_lambda_function.post_todo.invoke_arn
}

output "delete_todo_invoke_arn" {
  value = aws_lambda_function.delete_todo.invoke_arn
}
