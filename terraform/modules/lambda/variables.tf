variable "dynamodb_table_name" {
  description = "Lambda がアクセスする DynamoDB テーブル名"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "Lambda に付与する DynamoDB テーブルの ARN"
  type        = string
}
