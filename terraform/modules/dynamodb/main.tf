# --------------------------------------------------------------------------------
# DynamoDB テーブル
# TODO データを保存するためのテーブルです。
#
# 学習ポイント:
#   - billing_mode = "PAY_PER_REQUEST" → 読み書きした分だけ課金（学習用に最適）
#   - billing_mode = "PROVISIONED"     → キャパシティを事前に指定（本番向け）
#   - hash_key (パーティションキー)     → データの分散に使う一意のキー
#
# Phase 2 以降: RDS (MySQL/PostgreSQL) に置き換えてリレーショナル DB を学べます。
# --------------------------------------------------------------------------------
resource "aws_dynamodb_table" "todos" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S" # S = String, N = Number, B = Binary
  }

  tags = {
    Project = "todo-app"
    Phase   = "1"
  }
}
