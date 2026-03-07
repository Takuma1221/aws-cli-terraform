# --------------------------------------------------------------------------------
# Lambda 用 IAM ロール
# Lambda 関数が AWS サービス（CloudWatch Logs・DynamoDB）を操作するための権限です。
# 学習ポイント: 最小権限の原則 → 必要なアクションだけを許可する
# --------------------------------------------------------------------------------
resource "aws_iam_role" "lambda" {
  name = "todo-lambda-role"

  # Lambda サービスがこのロールを引き受け (Assume) できるようにする
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# CloudWatch Logs への書き込み権限（Lambda の実行ログ）
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DynamoDB への最小権限ポリシー
resource "aws_iam_role_policy" "dynamodb_access" {
  name = "todo-lambda-dynamodb-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:Scan",       # TODO 一覧取得
        "dynamodb:PutItem",    # TODO 作成
        "dynamodb:DeleteItem", # TODO 削除
      ]
      Resource = var.dynamodb_table_arn
    }]
  })
}

# --------------------------------------------------------------------------------
# Lambda デプロイパッケージ (ZIP)
# Terraform の archive_file でソースコードを ZIP 化します。
# source_code_hash により、コード変更時のみ自動で再デプロイされます。
# --------------------------------------------------------------------------------
data "archive_file" "get_todos" {
  type        = "zip"
  source_file = "${path.root}/../lambda/get_todos.py"
  output_path = "/tmp/lambda_builds/get_todos.zip"
}

data "archive_file" "post_todo" {
  type        = "zip"
  source_file = "${path.root}/../lambda/post_todo.py"
  output_path = "/tmp/lambda_builds/post_todo.zip"
}

data "archive_file" "delete_todo" {
  type        = "zip"
  source_file = "${path.root}/../lambda/delete_todo.py"
  output_path = "/tmp/lambda_builds/delete_todo.zip"
}

# --------------------------------------------------------------------------------
# Lambda 関数
# 環境変数 TABLE_NAME でテーブル名を渡します（ハードコードを避けるベストプラクティス）。
# --------------------------------------------------------------------------------
resource "aws_lambda_function" "get_todos" {
  filename         = data.archive_file.get_todos.output_path
  function_name    = "todo-get-todos"
  role             = aws_iam_role.lambda.arn
  handler          = "get_todos.handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.get_todos.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_function" "post_todo" {
  filename         = data.archive_file.post_todo.output_path
  function_name    = "todo-post-todo"
  role             = aws_iam_role.lambda.arn
  handler          = "post_todo.handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.post_todo.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_function" "delete_todo" {
  filename         = data.archive_file.delete_todo.output_path
  function_name    = "todo-delete-todo"
  role             = aws_iam_role.lambda.arn
  handler          = "delete_todo.handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.delete_todo.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}
