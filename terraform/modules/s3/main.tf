# --------------------------------------------------------------------------------
# S3 バケット
# --------------------------------------------------------------------------------
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
}

# パブリックアクセスを完全にブロック（CloudFront 経由のみ許可）
resource "aws_s3_bucket_public_access_block" "website" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --------------------------------------------------------------------------------
# 静的ファイルのアップロード
# etag でファイルの変更を検知し、変更時のみ再アップロードします。
# --------------------------------------------------------------------------------
resource "aws_s3_object" "index_html" {
  bucket        = aws_s3_bucket.website.bucket
  key           = "index.html"
  source        = "${path.root}/../website/index.html"
  content_type  = "text/html"
  cache_control = "no-cache, no-store, must-revalidate"
  etag          = filemd5("${path.root}/../website/index.html")
}

resource "aws_s3_object" "error_html" {
  bucket        = aws_s3_bucket.website.bucket
  key           = "error.html"
  source        = "${path.root}/../website/error.html"
  content_type  = "text/html"
  cache_control = "no-cache, no-store, must-revalidate"
  etag          = filemd5("${path.root}/../website/error.html")
}

resource "aws_s3_object" "auth_callback_html" {
  bucket        = aws_s3_bucket.website.bucket
  key           = "auth/callback.html"
  source        = "${path.root}/../website/auth-callback.html"
  content_type  = "text/html"
  cache_control = "no-cache, no-store, must-revalidate"
  etag          = filemd5("${path.root}/../website/auth-callback.html")
}

resource "aws_s3_object" "logout_html" {
  bucket        = aws_s3_bucket.website.bucket
  key           = "logout.html"
  source        = "${path.root}/../website/logout.html"
  content_type  = "text/html"
  cache_control = "no-cache, no-store, must-revalidate"
  etag          = filemd5("${path.root}/../website/logout.html")
}
