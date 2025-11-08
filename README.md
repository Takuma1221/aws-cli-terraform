# Terraform で AWS S3 バケットを作成するプロジェクト

このプロジェクトは、Terraform を使用して AWS S3 バケットを作成し、セキュアな設定とファイルアップロードを行うサンプルコードです。

## 📋 概要

このプロジェクトでは以下のリソースを作成します：

- **S3 バケット**: データ保存用のバケット
- **パブリックアクセスブロック**: セキュリティのためパブリックアクセスを禁止
- **S3 オブジェクト**: サンプルの HTML ファイルをアップロード

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

### アップロードファイルの変更

アップロードするファイルを変更する場合は、以下の行を編集します：

```hcl
resource "aws_s3_object" "example_file" {
  bucket = aws_s3_bucket.example_bucket.bucket
  key    = "index.html"
  source = "./../aws-weekly-study/index.html"  # ← ファイルパスを変更
  acl    = "private"
}
```

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
├── terraform.tfstate          # Terraform の状態ファイル（自動生成）
├── terraform.tfstate.backup   # 状態ファイルのバックアップ（自動生成）
└── README.md                  # このファイル
```

## 🔒 セキュリティ設定

このコードには以下のセキュリティ設定が含まれています：

- **パブリックアクセスブロック**: すべてのパブリックアクセスを禁止
- **プライベート ACL**: アップロードされたファイルはプライベート設定

## ⚠️ 注意事項

1. **コスト**: S3 バケットの作成は無料ですが、ストレージやデータ転送には料金がかかる場合があります
2. **バケット名**: S3 バケット名は全世界で一意である必要があります
3. **State ファイル**: `terraform.tfstate` には機密情報が含まれる可能性があるため、Git にコミットしないでください
4. **リージョン**: デフォルトで `us-east-1` リージョンを使用しています。変更する場合は `main.tf` の `provider` ブロックを編集してください

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
Error: open ./../aws-weekly-study/index.html: no such file or directory
```

→ アップロードするファイルのパスを確認してください

## 📚 参考リンク

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [Terraform Tutorial](https://learn.hashicorp.com/terraform)

## 📄 ライセンス

このプロジェクトは学習目的で作成されています。

---

**作成日**: 2025年11月8日
