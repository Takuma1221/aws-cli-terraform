output "cloudfront_domain_name" {
  description = "CloudFront のドメイン名（ブラウザでアクセスする URL）"
  value       = "https://${module.cloudfront.domain_name}"
}

output "api_gateway_url" {
  description = "API Gateway のエンドポイント URL"
  value       = module.apigateway.api_endpoint
}

output "s3_bucket_name" {
  description = "S3 バケット名"
  value       = module.s3.bucket_id
}
