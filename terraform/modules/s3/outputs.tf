output "bucket_id" {
  description = "S3 バケット ID (= バケット名)"
  value       = aws_s3_bucket.website.id
}

output "bucket_arn" {
  description = "S3 バケット ARN"
  value       = aws_s3_bucket.website.arn
}

output "bucket_regional_domain_name" {
  description = "S3 バケットのリージョナルドメイン名（CloudFront のオリジンに使用）"
  value       = aws_s3_bucket.website.bucket_regional_domain_name
}
