# --------------------------------------------------------------------------------
# WAF IP セット (IPv4)
# scope = "CLOUDFRONT" は必ず us-east-1 で作成する必要があります。
# --------------------------------------------------------------------------------
resource "aws_wafv2_ip_set" "allowed_ipv4" {
  name               = "todo-allowed-ipv4"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.allowed_ip_v4
}

# WAF IP セット (IPv6)
resource "aws_wafv2_ip_set" "allowed_ipv6" {
  name               = "todo-allowed-ipv6"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV6"
  addresses          = var.allowed_ip_v6
}

# --------------------------------------------------------------------------------
# WAF Web ACL
# デフォルトはブロック。許可リストの IP のみアクセス可能（ホワイトリスト方式）。
# 学習ポイント: WAF は CloudFront / ALB / API Gateway に付与できます。
# --------------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "main" {
  name  = "todo-app-acl"
  scope = "CLOUDFRONT"

  default_action {
    block {} # リストにない IP はすべてブロック
  }

  rule {
    name     = "AllowIPv4"
    priority = 1
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowed_ipv4.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowIPv4"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AllowIPv6"
    priority = 2
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowed_ipv6.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowIPv6"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "todo-app-acl"
    sampled_requests_enabled   = true
  }
}

# --------------------------------------------------------------------------------
# CloudFront OAC (Origin Access Control)
# S3 へのアクセスを CloudFront からのみ許可するための設定です。
# 旧 OAI より安全で推奨されている方式です。
# --------------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "todo-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --------------------------------------------------------------------------------
# CloudFront ディストリビューション
# S3 をオリジンとして HTTPS 配信します。
# Phase 2 以降: ALB / API Gateway を第2オリジンとして追加できます。
# --------------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  web_acl_id          = aws_wafv2_web_acl.main.arn

  # オリジン: S3 バケット（OAC 経由）
  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_id                = "S3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  # デフォルトのキャッシュ動作（静的ファイル配信）
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https" # HTTP → HTTPS にリダイレクト

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl     = 0
    default_ttl = 3600  # 1時間キャッシュ
    max_ttl     = 86400 # 最大 24時間
  }

  # エラーページの設定（S3 の 403 は 404 として扱い error.html を返す）
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/error.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/error.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  # CloudFront デフォルト証明書 (*.cloudfront.net)
  # 独自ドメインを使う場合は ACM 証明書を指定します（Phase 3 以降）
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
