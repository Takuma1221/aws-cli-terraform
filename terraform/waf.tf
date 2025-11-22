# --------------------------------------------------------------------------------
# IP Set (IPv4)
# 許可するIPv4アドレスのリストを定義します。
# scope = "CLOUDFRONT" は、このIPセットがCloudFront用であることを示します。
# --------------------------------------------------------------------------------
resource "aws_wafv2_ip_set" "allowed_ipv4" {
  name               = "allowed-ipv4-set"
  description        = "Allowed IPv4 addresses"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.allowed_ip_v4
}

# --------------------------------------------------------------------------------
# IP Set (IPv6)
# 許可するIPv6アドレスのリストを定義します。
# IPv4とIPv6は別々のIPセットとして作成する必要があります。
# --------------------------------------------------------------------------------
resource "aws_wafv2_ip_set" "allowed_ipv6" {
  name               = "allowed-ipv6-set"
  description        = "Allowed IPv6 addresses"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV6"
  addresses          = var.allowed_ip_v6
}

# --------------------------------------------------------------------------------
# Web ACL (Web Access Control List)
# CloudFrontに適用するファイアウォールのルールセットです。
# デフォルトのアクションを「ブロック」にし、特定のIPのみを「許可」するホワイトリスト方式です。
# --------------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "ip_restriction" {
  name        = "ip-restriction-acl"
  description = "Allow specific IPs only"
  scope       = "CLOUDFRONT" # CloudFrontに適用する場合は必須

  # デフォルトのアクション: ルールにマッチしなかったリクエストをブロック
  default_action {
    block {}
  }

  # CloudWatchメトリクスの設定
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ip-restriction-acl"
    sampled_requests_enabled   = true
  }

  # ------------------------------------------------------------------------------
  # ルール1: IPv4許可リスト
  # 作成したIPv4 IPセットに含まれるIPアドレスからのアクセスを許可します。
  # ------------------------------------------------------------------------------
  rule {
    name     = "AllowIPv4"
    priority = 1 # 優先順位 (小さい数字が先に評価される)

    action {
      allow {} # マッチした場合のアクション: 許可
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

  # ------------------------------------------------------------------------------
  # ルール2: IPv6許可リスト
  # 作成したIPv6 IPセットに含まれるIPアドレスからのアクセスを許可します。
  # ------------------------------------------------------------------------------
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
}
