output "cloudfront_domain_name" {
  description = "CloudFrontのドメイン名"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFrontのディストリビューションID"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "s3_bucket_name" {
  description = "S3バケット名"
  value       = aws_s3_bucket.website_bucket.id
}
