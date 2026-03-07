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
