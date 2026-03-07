# Terraform で AWS サーバーレス TODO アプリ

S3 + CloudFront + Lambda + API Gateway + DynamoDB を使ったサーバーレス TODO アプリです。
Terraform のモジュール構成で実装しており、Phase 2 以降で VPC / RDS / EC2 に段階的に拡張できます。

## アーキテクチャ

    ブラウザ --HTTPS--> CloudFront (WAF IP制限) --> S3 (index.html, error.html)

    ブラウザ --HTTPS--> API Gateway --> Lambda --> DynamoDB
                       (URL は /api-config.json から取得)

| サービス | 役割 |
|---|---|
| S3 | 静的ファイルのホスティング (HTML/CSS/JS) |
| CloudFront | CDN・HTTPS 化・WAF による IP 制限 |
| API Gateway | HTTP API エンドポイント (GET/POST/DELETE) |
| Lambda | ビジネスロジック (Python 3.12) |
| DynamoDB | TODO データの永続化 (NoSQL) |

## ディレクトリ構成

    terraform/
      main.tf                      # モジュールの呼び出しと接続
      variables.tf / outputs.tf / providers.tf
      terraform.tfvars.example     # 設定のサンプル
      modules/
        s3/          # S3 バケット・ファイルアップロード
        cloudfront/  # CloudFront ディストリビューション・WAF
        apigateway/  # HTTP API・ルーティング
        lambda/      # Lambda 関数・IAM ロール
        dynamodb/    # DynamoDB テーブル
    lambda/
      get_todos.py   # GET /todos
      post_todo.py   # POST /todos
      delete_todo.py # DELETE /todos/{id}
    website/
      index.html / error.html
    archive/
      phase0-byte-counter/  # 旧プロジェクト (バイトカウンター)

## セットアップ

### 1. 前提条件

- Terraform v1.0 以上
- AWS CLI + 認証情報の設定 (`aws configure`)

### 2. tfvars の作成

    cd terraform
    cp terraform.tfvars.example terraform.tfvars
    # terraform.tfvars を編集して bucket_name と allowed_ip_v4 を設定する
    # IPv4 確認: curl -4 ifconfig.me

### 3. デプロイ

    cd terraform
    terraform init
    terraform plan
    terraform apply

apply 完了後に表示される `cloudfront_domain_name` をブラウザで開くと TODO アプリが使えます。

CloudFront の反映には最大 5 分かかることがあります。

### 4. 削除

    terraform destroy

## モジュール間の依存関係

    module.dynamodb
        ---> module.lambda       (DynamoDB ARN を受け取る)
                 ---> module.apigateway  (Lambda ARN を受け取る)

    module.s3
        ---> module.cloudfront   (S3 ドメイン名を受け取る)
        ---> aws_s3_bucket_policy (CloudFront ARN を受け取る  循環参照をここで断ち切る)

## 今後の拡張 (ロードマップ)

| Phase | 内容 | 新たに学べるサービス |
|---|---|---|
| 1 (現在) | サーバーレス構成 | S3, CloudFront, Lambda, API Gateway, DynamoDB |
| 2 | VPC + RDS に移行 | VPC, Subnet, Security Group, RDS (MySQL) |
| 3 | EC2 / コンテナ化 | EC2, ALB, ECS (Fargate) |
