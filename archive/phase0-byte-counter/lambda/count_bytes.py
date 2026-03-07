import json

def handler(event, context):
    print("Received event:", json.dumps(event)) # ログ出力用

    try:
        # リクエストボディがあるか確認
        if 'body' not in event or event['body'] is None:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'error': 'No body provided'})
            }

        # ボディをパース (API Gatewayからの入力は文字列になっている場合がある)
        body_str = event['body']
        if isinstance(body_str, str):
            body = json.loads(body_str)
        else:
            body = body_str

        input_text = body.get('text', '')
        
        # バイト数を計算 (UTF-8エンコーディング)
        byte_length = len(input_text.encode('utf-8'))

        # 結果を返す
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*' # CORS許可 (どのサイトからでも呼べるようにする)
            },
            'body': json.dumps({
                'input_text': input_text,
                'byte_length': byte_length,
                'message': f"入力されたテキストは {byte_length} バイトです。"
            }, ensure_ascii=False)
        }

    except Exception as e:
        print("Error:", str(e))
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': 'Internal Server Error'})
        }
