# --------------------------------------------------------------------------------
# Cognito User Pool
# 認証基盤としてユーザー登録・ログイン・トークン発行を担当します。
# --------------------------------------------------------------------------------
resource "aws_cognito_user_pool" "main" {
  # User Pool はユーザー管理本体。認証用の DB 兼ログイン基盤のような役割。
  name = var.user_pool_name

  # email を verification 対象にする。形式チェックではなく本人が受信できるかの確認。
  auto_verified_attributes = ["email"]

  # ログイン ID は email を使う。
  username_attributes = ["email"]

  # パスワードポリシー。Cognito 側で最低限の強度を強制する。
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  # 確認メールはコード入力方式にする。
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  # 管理者だけでなく一般ユーザー自身でサインアップ可能にする。
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
}

# Hosted UI からログインするクライアント
resource "aws_cognito_user_pool_client" "main" {
  # User Pool Client は User Pool を使う「アプリ側の登録情報」。
  name         = "${var.user_pool_name}-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # ブラウザで使う公開クライアントなので secret は持たせない。
  generate_secret = false

  # ログインとトークン更新に必要な認証フローを許可する。
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  # Hosted UI / OAuth を使うための設定。code flow で JWT を取得する。
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

  # 今回の ID プロバイダは Cognito 自身のみ。Google 等はまだ使わない。
  supported_identity_providers = ["COGNITO"]

  # ログイン後・ログアウト後にフロントへ戻す URL。
  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls
}

# Hosted UI 用のドメイン
resource "aws_cognito_user_pool_domain" "main" {
  # Cognito が提供するログイン画面の URL prefix。
  domain       = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.main.id
}
