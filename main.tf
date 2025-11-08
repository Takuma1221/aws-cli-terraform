provider "aws" {
  region = "us-east-1"
}

# S3バケット作成
resource "aws_s3_bucket" "example_bucket" {
  bucket = "takuma-demo-bucket-20251108-01"
}

# S3バケットを静的ウェブサイトホスティングとして設定
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.example_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# バケットポリシー(例:パブリックアクセスを禁止)
resource "aws_s3_bucket_public_access_block" "example_block" {
  bucket = aws_s3_bucket.example_bucket.id

  block_public_acls       = true
  block_public_policy     = false # IP制限のためにポリシーを許可
  ignore_public_acls      = true
  restrict_public_buckets = false # IP制限のためにfalseに変更
}

# IP制限付きバケットポリシー
resource "aws_s3_bucket_policy" "ip_restriction" {
  bucket = aws_s3_bucket.example_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "IPRestrictionAllow"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.example_bucket.arn}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = [
              "106.72.160.97/32",       # あなたの現在のIPv4アドレス
              "240b:10:a061:fe00::/64", # あなたのIPv6アドレス範囲
            ]
          }
        }
      },
      {
        Sid       = "IPRestrictionDeny"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.example_bucket.arn}",
          "${aws_s3_bucket.example_bucket.arn}/*"
        ]
        Condition = {
          NotIpAddress = {
            "aws:SourceIp" = [
              "106.72.160.97/32",       # あなたの現在のIPv4アドレス
              "240b:10:a061:fe00::/64", # あなたのIPv6アドレス範囲
            ]
          }
        }
      }
    ]
  })
}

# ファイルをアップロード
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.example_bucket.bucket
  key          = "index.html"
  source       = "./website/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error_html" {
  bucket       = aws_s3_bucket.example_bucket.bucket
  key          = "error.html"
  source       = "./website/error.html"
  content_type = "text/html"
}

# ウェブサイトのURLを出力
output "website_endpoint" {
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
  description = "S3バケットのウェブサイトエンドポイント"
}

output "website_domain" {
  value       = aws_s3_bucket_website_configuration.website.website_domain
  description = "S3バケットのウェブサイトドメイン"
}
