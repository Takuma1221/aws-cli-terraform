import json
import os
import re

import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

# UUID v4 の形式チェック（インジェクション対策）
UUID_PATTERN = re.compile(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
)

def handler(event, context):
    """
    DELETE /todos/{id}
    指定した ID の TODO を DynamoDB から削除します。
    """
    try:
        todo_id = (event.get('pathParameters') or {}).get('id', '')

        # --- バリデーション ---
        if not todo_id:
            return _response(400, {'error': 'id は必須です'})

        if not UUID_PATTERN.match(todo_id):
            return _response(400, {'error': 'id の形式が不正です'})

        # --- DynamoDB から削除 ---
        # ConditionExpression で「存在する場合のみ削除」を保証します
        table.delete_item(
            Key={'id': todo_id},
            ConditionExpression='attribute_exists(id)',
        )

        return _response(200, {'message': f'Todo {todo_id} を削除しました'})

    except ClientError as e:
        if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
            return _response(404, {'error': '指定された TODO が見つかりません'})
        print(f"DynamoDB error: {e}")
        return _response(500, {'error': 'Internal server error'})

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
