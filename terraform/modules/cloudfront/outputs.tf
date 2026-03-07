output "distribution_arn" {
  description = "CloudFront ディストリビューション ARN（バケットポリシーに使用）"
  value       = aws_cloudfront_distribution.main.arn
}

output "distribution_id" {
  description = "CloudFront ディストリビューション ID"
  value       = aws_cloudfront_distribution.main.id
}

output "domain_name" {
  description = "CloudFront ドメイン名 (xxxx.cloudfront.net)"
  value       = aws_cloudfront_distribution.main.domain_name
}
