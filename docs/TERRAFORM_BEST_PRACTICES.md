# Terraform ベストプラクティスガイド

Terraform を安全かつ効率的に運用するための推奨事項をまとめました。

## 1. ディレクトリ構成とファイル分割

コードの見通しを良くするために、リソースごとにファイルを分割することを推奨します。

### 推奨構成
```
.
├── main.tf          # プロバイダー設定や共通設定（またはエントリーポイント）
├── variables.tf     # 変数の定義（型や説明のみ）
├── outputs.tf       # 出力値の定義（作成されたリソースのIDやURLなど）
├── terraform.tfvars # 変数の具体的な値（Gitにはコミットしない場合が多い）
├── versions.tf      # Terraformやプロバイダーのバージョン固定
├── s3.tf            # S3関連リソース
├── cloudfront.tf    # CloudFront関連リソース
└── waf.tf           # WAF関連リソース
```

### メリット
- **可読性向上**: どこに何が書いてあるか探しやすくなります。
- **競合回避**: チーム開発時に同じファイルを同時に編集するリスクが減ります。

---

## 2. 変数の管理 (`variables.tf` と `terraform.tfvars`)

### ルール
- **`variables.tf`**: 変数の「宣言」のみを行います。`default` 値は極力使わず、必須項目とします。必ず `description` と `type` を記述します。
- **`terraform.tfvars`**: 変数の「値」を記述します。
- **機密情報**: パスワードやAPIキーなどの機密情報は `terraform.tfvars` に書き、このファイルを `.gitignore` に追加してリポジトリに含めないようにします（代わりに `terraform.tfvars.example` を置く）。

### 例
**variables.tf**
```hcl
variable "environment" {
  description = "デプロイ環境 (dev, stg, prod)"
  type        = string
}
```

**terraform.tfvars**
```hcl
environment = "dev"
```

---

## 3. State（状態）の管理

Terraform は `terraform.tfstate` ファイルで現在のインフラの状態を管理しています。

### 推奨事項
- **リモートバックエンドの使用**: 本番運用では、ローカルではなく S3 などのリモートストレージ（Backend）に State ファイルを保存します。
    - **メリット**: チームで状態を共有できる、PCが壊れても復旧できる、排他制御（Lock）ができる。
- **State ファイルを触らない**: 手動で編集してはいけません。修正が必要な場合は `terraform state` コマンドを使用します。

---

## 4. 命名規則

リソース名や変数名は一貫性を持たせます。

- **リソース名**: `aws_s3_bucket.main` や `aws_s3_bucket.logs` のように、役割がわかる一般的な名前を使います（リソースタイプ名を含める必要はありません）。
- **変数名**: `snake_case`（スネークケース）を使用します。

---

## 5. フォーマットと検証

コミット前に必ず以下のコマンドを実行して、コードの品質を保ちます。

- **`terraform fmt`**: コードのインデントやスペースを自動整形します。
- **`terraform validate`**: 構文エラーがないかチェックします。

---

## 6. バージョン固定

`versions.tf` などで、Terraform 本体とプロバイダー（AWSなど）のバージョンを固定します。
予期せぬバージョンアップによる破壊的な変更を防ぐためです。

```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```
