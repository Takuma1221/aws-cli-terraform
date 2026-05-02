# Current Learning And Implementation Plan

## 現在地

このリポジトリは、Terraform で AWS の最小サーバーレス構成を学ぶための教材として使っている。

現状の構成は次の通り。

- フロント配信: S3 + CloudFront
- アクセス制御: WAF（CloudFront 前段の IP 制限）
- API: API Gateway HTTP API
- 実処理: Lambda (Python)
- データ保存: DynamoDB

現在の TODO アプリは、ユーザーごとに TODO を分離する設計まで進んでいる。

- Cognito でログインできる
- API Gateway が JWT を検証する
- DynamoDB は user_id 単位の設計になっている
- Lambda は JWT claims の user_id を使って自分の TODO だけを扱う

## ここまでに理解したこと

### Terraform 全般

- `variables.tf` は変数の型・説明・デフォルト値の定義
- `terraform.tfvars` は実際に入れる値
- `outputs.tf` は親モジュールや apply 後に見せる値の出口
- モジュール構成にすると責務が分かれ、ルート `main.tf` は配線図として読める

### S3

- 非公開バケットを作り、`index.html` と `error.html` をアップロードする
- `bucket_regional_domain_name` などの属性を outputs で CloudFront 側へ渡す

### CloudFront / WAF

- CloudFront は S3 をオリジンにして静的ファイルを配る
- OAC により CloudFront が署名付きで S3 を読む
- S3 側でも CloudFront Distribution からのアクセスだけ許可する必要がある
- WAF は IP ホワイトリスト方式で CloudFront の前段に置く
- `visibility_config` は観測用（CloudWatch メトリクス / sampled requests）

### API Gateway

- HTTP API を使っている
- CORS はブラウザから別オリジン API を呼ぶための許可設定
- `OPTIONS` はプリフライト用の事前確認リクエスト
- `integration / route / permission` の 3 点セットで Lambda と接続する
  - `route`: 何を受けるか
  - `integration`: どこに流すか
  - `permission`: 呼んでよいか

### Lambda

- `handler(event, context)` が入口
- API Gateway からの入力は `event` に入る
- 戻り値は `statusCode / headers / body` 形式
- DynamoDB テーブル名はハードコードせず環境変数 `TABLE_NAME` で渡す
- `archive_file` で ZIP を作り、その ZIP を `aws_lambda_function` に紐づけている

### DynamoDB

- DynamoDB は RDB ではなく NoSQL
- 今のテーブルは `user_id` をパーティションキー、`todo_id` をソートキーにした複合キー構成
- `scan()` は全件走査、`query()` はキーを使った効率的取得
- 今の TODO アプリでは自分の TODO 取得に `query()` を使っている

### Cognito

- Cognito は AWS の認証サービス
- User Pool は「認証機能付きのユーザー管理基盤」
- User Pool Client はその認証基盤を使うアプリ側の登録情報
- `auto_verified_attributes = ["email"]` はメール形式チェックではなく、メールアドレス所有確認
- Hosted UI は Cognito が提供するログイン画面
- JWT Authorizer は API Gateway で JWT を検証する仕組み

## 実装方針

次は TODO アプリを「認証付き TODO アプリ」に拡張する。

ゴールは次の状態。

- ユーザーが Cognito でログインできる
- フロントが JWT を持って API を呼べる
- API Gateway が JWT を検証する
- TODO はユーザーごとに分離される
- 他人の TODO を見たり削除したりできない

## フェーズ構成

### Phase 1: Cognito 基盤を追加する

実装済みの内容:

- `terraform/modules/cognito/` を追加
- User Pool を追加
- User Pool Client を追加
- Hosted UI Domain を追加
- ルート `main.tf` から Cognito モジュールを呼び出すようにした
- `api-config.json` に Cognito 情報も載せるようにした

この段階ではまだログイン画面や API 認証は未接続。

### Phase 2: フロントからログインできるようにする

実装済みの内容:

- `website/index.html` にログイン導線を追加
- Hosted UI に遷移できるようにした
- ログイン後の token をブラウザで受け取れるようにした
- `Authorization` ヘッダ付きで API を呼べるようにした
- 分かりやすいように callback 用画面 / logout 完了画面も追加した

### Phase 3: API Gateway に JWT Authorizer を付ける

実装済みの内容:

- Cognito の User Pool / Client を参照する JWT Authorizer を追加
- `GET /todos`, `POST /todos`, `DELETE /todos/{id}` に認証を必須化した
- 認証されていないリクエストは API Gateway で落ちるようにした
- CORS で `Authorization` ヘッダも許可した

### Phase 4: DynamoDB をユーザー単位設計に変更する

実装済みの内容:

- テーブル設計を `user_id` + `todo_id` の複合キーへ変更した
- `scan()` 前提ではなく `query()` 前提へ切り替えた
- 自分の TODO だけ取得しやすい構造にした

### Phase 5: Lambda をユーザー対応に変更する

実装済みの内容:

- JWT claims からユーザー ID を取得するようにした
- `get_todos.py` を `scan()` から `query()` に変更した
- `post_todo.py` で `user_id` を保存するようにした
- `delete_todo.py` で自分の TODO のみ削除できるようにした

## 次にやるべきこと

優先順は次の通り。

1. Terraform apply 後に、ユーザーごとに TODO が分離されることを確認する
2. 別ユーザーを作って、自分の TODO しか見えないことを確認する
3. 必要なら TODO の更新機能や完了状態変更を追加する

## その先のステップ

このドキュメントでは次のステップとして、機能拡張と検証の方向を追っていく。

- 複数ユーザーでの分離確認
- TODO 更新機能の追加
- 必要なら GSI や完了状態での絞り込み

## 補足メモ

- CloudFront と API Gateway は現状並列の入口
- フロントは静的配信、API は動的処理という分担
- React / Next.js のようなフロントでも、静的配信と動的 API を分ける構成は一般的
- 複雑なアプリになっても、すぐに EC2 が必要とは限らず、まず Lambda / ECS / Fargate を比較する
- C# や TypeScript でも Lambda 構成は可能で、Python に書き換え必須ではない
