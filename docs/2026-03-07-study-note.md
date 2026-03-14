# 2026-03-07 Study Note

今日は S3 から API Gateway までの構成と Terraform の読み方を確認した。

## 全体構成

このプロジェクトは経路が 2 本ある。

- 画面表示: Browser -> CloudFront -> S3
- API 呼び出し: Browser -> API Gateway -> Lambda -> DynamoDB

CloudFront と API Gateway は直列ではなく、役割の異なる入口として並列に存在する。

## Terraform の基本整理

- `variables.tf`: 変数の型、説明、デフォルト値を定義する
- `terraform.tfvars`: 実際の値を入れる
- `providers.tf`: AWS provider や backend を定義する
- `outputs.tf`: 外へ渡す値、または apply 後に表示したい値を定義する

モジュール配下の `outputs.tf` は親モジュールへの受け渡し口になる。

## S3 モジュールで理解したこと

- S3 バケットを作成する
- Public Access Block で直接の公開アクセスを止める
- `index.html` と `error.html` を S3 にアップロードする
- `bucket_regional_domain_name` は S3 リソース属性を output として公開して CloudFront 側へ渡している

S3 だけでは CloudFront からの読取は許可されず、ルートの `terraform/main.tf` にあるバケットポリシーで CloudFront だけを許可している。

## CloudFront / WAF で理解したこと

- CloudFront は S3 をオリジンとして静的ファイルを配信する
- WAF は CloudFront の前段で IP 制限を行う
- `allowed_ip_v4` / `allowed_ip_v6` は `terraform.tfvars` から渡されるホワイトリスト
- `default_action { block {} }` により、許可リストにないアクセスは拒否される
- `visibility_config` は CloudWatch メトリクスやサンプルリクエストの観測用設定

### OAC

`aws_cloudfront_origin_access_control` は CloudFront が S3 へ署名付きでアクセスするための設定。

- `origin_access_control_origin_type = "s3"`: S3 向け設定
- `signing_behavior = "always"`: 毎回署名する
- `signing_protocol = "sigv4"`: Signature V4 を使う

CloudFront 側で OAC を使う設定と、S3 側で CloudFront の Distribution ARN を許可する設定の両方が必要。

### CloudFront Distribution

- `default_root_object = "index.html"`: `/` で `index.html` を返す
- `origin`: どの S3 を読みに行くか
- `default_cache_behavior`: GET/HEAD を許可してキャッシュする
- `viewer_protocol_policy = "redirect-to-https"`: HTTP を HTTPS にリダイレクト
- `custom_error_response`: 403/404 を `error.html` で返す

今回 IPv6 を有効にしていたため、IPv6 の許可が空だと CloudFront では `error.html` が返り得ることを確認した。

## API Gateway で理解したこと

HTTP API を使っている。

- `aws_apigatewayv2_api`: API 本体
- `aws_apigatewayv2_stage`: 公開ステージ
- `auto_deploy = true`: 変更を自動でデプロイする

### CORS

ブラウザが別オリジンの API を呼ぶための許可設定。

- `allow_origins = ["*"]`: どのオリジンからでも呼べる
- 本番では CloudFront ドメインに絞るのが望ましい
- `OPTIONS` はプリフライト用。ブラウザが本リクエスト前に事前確認として送る

### route / integration / permission

各 API は 3 点セットで定義されている。

- `integration`: API Gateway がどの Lambda を呼ぶか
- `route`: どの HTTP メソッドとパスをその integration に流すか
- `aws_lambda_permission`: API Gateway がその Lambda を invoke してよい権限

今回のルートは次の 3 つ。

- `GET /todos` -> `get_todos` Lambda
- `POST /todos` -> `post_todo` Lambda
- `DELETE /todos/{id}` -> `delete_todo` Lambda

### invoke

`invoke` は Lambda を実際に実行すること。

- `invoke_arn`: API Gateway などが Lambda を呼ぶ時に使う ARN
- `arn`: Lambda リソース自体を識別する ARN

## 実機確認で分かったこと

- API Gateway のルート `/` は未定義なので 404 になる
- `GET /todos` は正常に動作し、空配列が返ることを確認した
- CloudFront 側は IPv4 では 200、IPv6 では WAF 条件次第で `error.html` が返ることを確認した

## 次回の続き

- Lambda の各関数を読む
- DynamoDB のテーブル定義を読む
- 必要なら CloudFront 配下に API Gateway をぶら下げる構成も比較する
