import json
import os
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def handler(event, context):
    """
    GET /todos
    ログインユーザー自身の TODO を返します。
    """
    try:
        user_id = _get_user_id(event)
        if not user_id:
            return _response(401, {'error': 'Unauthorized'})

        response = table.query(
            KeyConditionExpression=Key('user_id').eq(user_id)
        )
        todos = response.get('Items', [])

        for todo in todos:
            todo['id'] = todo.get('todo_id', '')

        # 作成日時の降順で並び替え（新しい順）
        todos.sort(key=lambda x: x.get('created_at', ''), reverse=True)

        return _response(200, todos)

    except Exception as e:
        print(f"Error: {e}")
        return _response(500, {'error': 'Internal server error'})


def _get_user_id(event):
    claims = (((event.get('requestContext') or {}).get('authorizer') or {}).get('jwt') or {}).get('claims') or {}
    return claims.get('sub')


def _response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
        },
        'body': json.dumps(body, ensure_ascii=False),
    }
