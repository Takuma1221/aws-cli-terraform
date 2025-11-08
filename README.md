# Terraform で AWS S3 静的ウェブサイトホスティング + IP制限

このプロジェクトは、Terraform を使用して AWS S3 バケットで静的ウェブサイトをホスティングし、IP制限によるアクセス制御を行うサンプルコードです。

## 📋 概要

このプロジェクトでは以下のリソースを作成します：

- **S3 バケット**: 静的ウェブサイトホスティング用のバケット
- **ウェブサイト設定**: `index.html` と `error.html` を使った静的サイト
- **IP制限付きバケットポリシー**: 特定のIPアドレスからのみアクセスを許可
- **パブリックアクセスブロック**: セキュアなアクセス制御
- **S3 オブジェクト**: HTML ファイル（index.html, error.html）をアップロード

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

プロジェクトディレクトリで以下のコマンドを実行：

```bash
terraform init
```

## 📝 使い方

### バケット名の変更

`main.tf` ファイルの以下の行を編集して、バケット名を変更できます：

```hcl
resource "aws_s3_bucket" "example_bucket" {
  bucket = "takuma-demo-bucket-20251108-01"  # ← ここを変更
}
```

> **注意**: S3 バケット名は全世界で一意である必要があります。

### IP制限の設定

許可するIPアドレスを変更する場合は、`main.tf` の以下の部分を編集します：

```hcl
"aws:SourceIp" = [
  "106.72.160.97/32",       # IPv4アドレス（/32は単一IP）
  "240b:10:a061:fe00::/64", # IPv6アドレス範囲
]
```

現在のIPアドレスを確認：

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

デプロイ後、出力されるURLにアクセスします：

```bash
terraform output website_endpoint
```

ブラウザで表示されたURLを開いてウェブサイトを確認できます。

> **注意**: IP制限が有効なため、設定したIPアドレス以外からはアクセスできません。

### リソースの削除

作成したリソースを削除する場合：

```bash
terraform destroy
```

確認プロンプトで `yes` と入力してください。

## 📂 ファイル構成

```
aws-cli-terraform/
├── main.tf                    # メインの Terraform 設定ファイル
├── website/
│   ├── index.html            # ウェブサイトのトップページ
│   └── error.html            # エラーページ
├── terraform.tfstate          # Terraform の状態ファイル（自動生成）
├── terraform.tfstate.backup   # 状態ファイルのバックアップ（自動生成）
└── README.md                  # このファイル
```

## 🔒 セキュリティ設定

このコードには以下のセキュリティ設定が含まれています：

- **IP制限**: 特定のIPアドレスからのみアクセスを許可
  - 許可されたIPからの `s3:GetObject` を許可
  - それ以外のIPからのすべてのアクセスを拒否
- **パブリックアクセスブロック**: パブリックACLをブロック
- **静的ウェブサイトホスティング**: セキュアなウェブサイト公開

## ⚠️ 注意事項

1. **コスト**: S3 バケットの作成は無料ですが、ストレージやデータ転送には料金がかかる場合があります
2. **バケット名**: S3 バケット名は全世界で一意である必要があります
3. **State ファイル**: `terraform.tfstate` には機密情報が含まれる可能性があるため、Git にコミットしないでください
4. **リージョン**: デフォルトで `us-east-1` リージョンを使用しています。変更する場合は `main.tf` の `provider` ブロックを編集してください
5. **IP制限**: 設定したIPアドレス以外からはアクセスできません。IPアドレスが変更された場合は `main.tf` を更新して再デプロイしてください

## 🌐 アクセス方法

デプロイ後、以下のコマンドでウェブサイトURLを確認：

```bash
terraform output website_endpoint
```

出力例：
```
http://takuma-demo-bucket-20251108-01.s3-website-us-east-1.amazonaws.com
```

このURLにブラウザでアクセスすると、ウェブサイトが表示されます（許可されたIPからのみ）。

## 🛠️ トラブルシューティング

### バケット名の重複エラー

```
Error: creating Amazon S3 Bucket: BucketAlreadyExists
```

→ バケット名を変更してください（全世界で一意である必要があります）

### 認証エラー

```
Error: error configuring Terraform AWS Provider: no valid credential sources
```

→ `aws configure` で認証情報を正しく設定してください

### ファイルが見つからないエラー

```
Error: open ./website/index.html: no such file or directory
```

→ `website/` ディレクトリにHTMLファイルを配置してください

### IP制限によるアクセス拒否

ウェブサイトにアクセスできない場合：

1. 現在のIPアドレスを確認: `curl -4 ifconfig.me`
2. `main.tf` のIPアドレス設定を更新
3. `terraform apply` で再デプロイ

## 📚 参考リンク

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [Terraform Tutorial](https://learn.hashicorp.com/terraform)

## 📄 ライセンス

このプロジェクトは学習目的で作成されています。

---

**作成日**: 2025 年 11 月 8 日
