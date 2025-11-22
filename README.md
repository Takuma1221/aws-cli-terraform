# Terraform で AWS CloudFront + S3 静的ウェブサイトホスティング (WAF IP 制限付き)

このプロジェクトは、Terraform を使用して AWS CloudFront + S3 で静的ウェブサイトをホスティングし、AWS WAF を使用して IP 制限によるアクセス制御を行うサンプルコードです。

## 📋 概要

このプロジェクトでは以下のリソースを作成します：

- **CloudFront**: CDN による高速配信と HTTPS 化
- **S3 バケット**: コンテンツのオリジン（OAC により CloudFront からのみアクセス許可）
- **AWS WAF**: IP 制限（許可された IP 以外からのアクセスをブロック）
- **S3 オブジェクト**: HTML ファイル（index.html, error.html）をアップロード

詳細な構成比較については [docs/ARCHITECTURE_COMPARISON.md](docs/ARCHITECTURE_COMPARISON.md) を参照してください。

## 🚀 前提条件

以下のツールがインストールされている必要があります：

- [Terraform](https://www.terraform.io/downloads.html) (v1.0 以上推奨)
- [AWS CLI](https://aws.amazon.com/cli/)
- AWS アカウントと適切な認証情報

## 🔧 セットアップ

### 1. AWS 認証情報の設定

AWS CLI で認証情報を設定します：

```bash
aws configure
```

以下の情報を入力してください：

- AWS Access Key ID
- AWS Secret Access Key
- Default region name (例: us-east-1)
- Default output format (例: json)

### 2. Terraform の初期化

Terraform ディレクトリに移動して初期化します：

```bash
cd terraform
terraform init
```

## 📝 使い方

### 設定の変更 (variables.tf)

`terraform/variables.tf` ファイルを編集して、バケット名や許可 IP を変更できます。

**バケット名の変更:**

```hcl
variable "bucket_name" {
  default = "takuma-demo-bucket-20251108-01" # ← ここを変更
}
```

**IP 制限の設定:**

```hcl
variable "allowed_ip_v4" {
  default = ["106.72.160.97/32"] # ← あなたのIPv4アドレス
}

variable "allowed_ip_v6" {
  default = ["240b:10:a061:fe00::/64"] # ← あなたのIPv6アドレス範囲
}
```

現在の IP アドレスを確認：

```bash
# IPv4
curl -4 ifconfig.me

# IPv6
curl -6 ifconfig.me
```

### アップロードファイルの変更

ウェブサイトファイルは `website/` ディレクトリに配置します：

- `website/index.html` - トップページ
- `website/error.html` - エラーページ

### 実行計画の確認

変更内容を確認：

```bash
terraform plan
```

### リソースの作成

実際にリソースを作成：

```bash
terraform apply
```

確認プロンプトで `yes` と入力してください。

### ウェブサイトの確認

デプロイ後、出力される CloudFront ドメイン名にアクセスします：

```bash
terraform output cloudfront_domain_name
```

ブラウザで `https://<CloudFrontドメイン>` を開いてウェブサイトを確認できます。

> **注意**: IP 制限が有効なため、設定した IP アドレス以外からはアクセスできません（403 Forbidden が返されます）。

### リソースの削除

作成したリソースを削除する場合：

```bash
terraform destroy
```

確認プロンプトで `yes` と入力してください。

## 📂 ファイル構成

```
aws-cli-terraform/
├── docs/
│   └── ARCHITECTURE_COMPARISON.md # 構成比較ドキュメント
├── terraform/                 # Terraform コード
│   ├── cloudfront.tf          # CloudFront 設定
│   ├── s3.tf                  # S3 バケット設定
│   ├── waf.tf                 # WAF (IP制限) 設定
│   ├── variables.tf           # 変数定義
│   ├── outputs.tf             # 出力定義
│   ├── providers.tf           # プロバイダー設定
│   ├── terraform.tfstate      # 状態ファイル
│   └── terraform.tfstate.backup
├── website/                   # ウェブサイトコンテンツ
│   ├── index.html
│   └── error.html
└── README.md                  # このファイル
```

## 🔒 セキュリティ設定

このコードには以下のセキュリティ設定が含まれています：

- **S3 パブリックアクセスブロック**: すべてのパブリックアクセスを禁止
- **OAC (Origin Access Control)**: CloudFront からのアクセスのみを許可し、S3 への直接アクセスを禁止
- **AWS WAF**: 指定した IP アドレス以外からのアクセスをブロック
- **HTTPS**: CloudFront による SSL/TLS 暗号化通信

## ⚠️ 注意事項

1. **コスト**:
   - **AWS WAF**: Web ACL ($5/月) + ルール ($1/月) の料金が発生します。**使用後は必ず削除してください。**
   - **CloudFront**: データ転送量に応じた料金が発生します。
2. **反映時間**: CloudFront の作成・更新には数分〜15 分程度かかる場合があります。
3. **バケット名**: S3 バケット名は全世界で一意である必要があります。
4. **State ファイル**: `terraform.tfstate` には機密情報が含まれる可能性があるため、Git にコミットしないでください。

## 🛠️ トラブルシューティング

### 403 Forbidden エラー

- **IP 制限**: 現在の IP アドレスが `variables.tf` に設定されているか確認してください。
- **OAC 設定**: S3 バケットポリシーが正しく CloudFront を許可しているか確認してください。

### 404 Not Found エラー

- `website/` ディレクトリにファイルが存在するか確認してください。
- CloudFront のキャッシュが残っている可能性があります。

## 📚 参考リンク

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amazon CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [AWS WAF Documentation](https://docs.aws.amazon.com/waf/)

## 📄 ライセンス

このプロジェクトは学習目的で作成されています。

---

**作成日**: 2025 年 11 月 22 日

**作成日**: 2025 年 11 月 8 日
