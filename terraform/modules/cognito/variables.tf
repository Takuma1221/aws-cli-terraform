variable "user_pool_name" {
  description = "Cognito User Pool 名"
  type        = string
}

variable "domain_prefix" {
  description = "Cognito Hosted UI のドメイン prefix"
  type        = string
}

variable "callback_urls" {
  description = "ログイン後のリダイレクト先 URL 一覧"
  type        = list(string)
}

variable "logout_urls" {
  description = "ログアウト後のリダイレクト先 URL 一覧"
  type        = list(string)
}
