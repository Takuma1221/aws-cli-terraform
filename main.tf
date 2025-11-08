provider "aws" {
  region = "us-east-1"
}

# S3バケット作成
resource "aws_s3_bucket" "example_bucket" {
  bucket = "takuma-demo-bucket-20251108-01"
}

# バケットポリシー（例：パブリックアクセスを禁止）
resource "aws_s3_bucket_public_access_block" "example_block" {
  bucket = aws_s3_bucket.example_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

# ファイルをアップロード
resource "aws_s3_object" "example_file" {
  bucket = aws_s3_bucket.example_bucket.bucket
  key    = "index.html"
  source = "./index.html"
  acl    = "private"
}
