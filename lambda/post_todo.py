import json
import os
import uuid
from datetime import datetime, timezone

import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def handler(event, context):
    """
    POST /todos
    リクエストボディ: {"title": "やること"}
    新しい TODO を DynamoDB に作成して返します。
    """
    try:
        body = json.loads(event.get('body') or '{}')
        title = body.get('title', '').strip()

        # --- バリデーション ---
        if not title:
            return _response(400, {'error': 'title は必須です'})

        if len(title) > 200:
            return _response(400, {'error': 'title は 200 文字以内にしてください'})

        # --- DynamoDB に保存 ---
        todo = {
            'id':         str(uuid.uuid4()),
            'title':      title,
            'done':       False,
            'created_at': datetime.now(timezone.utc).isoformat(),
        }
        table.put_item(Item=todo)

        return _response(201, todo)

    except Exception as e:
        print(f"Error: {e}")
        return _response(500, {'error': 'Internal server error'})


def _response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
        },
        'body': json.dumps(body, ensure_ascii=False),
    }
