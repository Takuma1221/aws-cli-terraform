# --------------------------------------------------------------------------------
# Lambda Function
# Pythonコードを実行するサーバーレス関数を定義します。
# --------------------------------------------------------------------------------

# Lambda用のIAMロール (Lambdaが他のAWSサービスを操作するための権限)
resource "aws_iam_role" "lambda_role" {
  name = "byte_counter_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambdaの基本的なログ出力権限を付与
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ソースコードをZIP化
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../lambda/count_bytes.py" # Terraformディレクトリから見たパス
  output_path = "lambda_function.zip"
}

# Lambda関数の作成
resource "aws_lambda_function" "byte_counter" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "byte-counter-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "count_bytes.handler" # ファイル名.関数名
  runtime       = "python3.9"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}
