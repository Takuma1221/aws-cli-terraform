# --------------------------------------------------------------------------------
# ルート変数定義
# terraform.tfvars で値を上書きして使います。
# --------------------------------------------------------------------------------

variable "bucket_name" {
  description = "S3 バケット名（全世界で一意である必要があります）"
  type        = string
}

variable "allowed_ip_v4" {
  description = "WAF で許可する IPv4 アドレス（CIDR形式のリスト）"
  type        = list(string)
}

variable "allowed_ip_v6" {
  description = "WAF で許可する IPv6 アドレス（CIDR形式のリスト）"
  type        = list(string)
  default     = []
}

variable "dynamodb_table_name" {
  description = "DynamoDB テーブル名"
  type        = string
  default     = "todos"
}

variable "cognito_user_pool_name" {
  description = "Cognito User Pool 名"
  type        = string
  default     = "todo-users"
}

variable "cognito_domain_prefix" {
  description = "Cognito Hosted UI のドメイン prefix（一意である必要があります）"
  type        = string
  default     = ""
}

variable "cognito_callback_urls" {
  description = "Cognito ログイン後のリダイレクト先 URL 一覧"
  type        = list(string)
  default     = ["http://localhost:3000"]
}

variable "cognito_logout_urls" {
  description = "Cognito ログアウト後のリダイレクト先 URL 一覧"
  type        = list(string)
  default     = ["http://localhost:3000"]
}
