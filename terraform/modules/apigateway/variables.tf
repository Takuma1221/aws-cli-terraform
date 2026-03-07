variable "lambda_get_todos_invoke_arn" {
  description = "GET /todos Lambda の invoke ARN"
  type        = string
}

variable "lambda_post_todo_invoke_arn" {
  description = "POST /todos Lambda の invoke ARN"
  type        = string
}

variable "lambda_delete_todo_invoke_arn" {
  description = "DELETE /todos/{id} Lambda の invoke ARN"
  type        = string
}

variable "lambda_get_todos_arn" {
  description = "GET /todos Lambda の ARN（実行権限付与に使用）"
  type        = string
}

variable "lambda_post_todo_arn" {
  description = "POST /todos Lambda の ARN（実行権限付与に使用）"
  type        = string
}

variable "lambda_delete_todo_arn" {
  description = "DELETE /todos/{id} Lambda の ARN（実行権限付与に使用）"
  type        = string
}
