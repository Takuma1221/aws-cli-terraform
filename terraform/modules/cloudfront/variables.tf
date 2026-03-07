variable "bucket_name" {
  description = "S3 バケット名（オリジン識別子として使用）"
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "S3 バケットのリージョナルドメイン名"
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
