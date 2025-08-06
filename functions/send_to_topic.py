from itertools import cycle
import hashlib
import json
import os
from time import sleep

import boto3


def generate_hash(payload):
    json_str = json.dumps(payload, sort_keys=True)
    json_bytes = json_str.encode('utf-8')
    hash_md5 = hashlib.md5(json_bytes).hexdigest()

    return hash_md5


def lambda_handler(payload, context):

    topic_name = os.getenv('TOPIC_NAME')
    print(payload)

    hash_md5 = generate_hash(payload)
    res = boto3.client('iot-data').publish(
        topic=topic_name,
        payload=json.dumps({
            'led': payload['led'],
            'state': payload['state'],
            'hash': hash_md5,
            'callbackUrl': payload['callbackUrl']
        })
    )

    # make HTTP GET /lastHash to see if matches with mash_md5

    if res['ResponseMetadata']['HTTPStatusCode'] == 200:
        return {
            "statusCode": 200,
            "contentType": "application/json",
            "body": json.dumps({
                "message": f'Success changing {payload["led"]} LED state to {payload["state"]}'
            })
        }

    return {
        "statusCode": 500,
        "contentType": "application/json",
        "body": json.dumps({
            "message": 'Unable to change LED state'
        })
    }


if __name__ == '__main__':

    colors = ['blue', 'red', 'yellow', 'green']

    for color in cycle(colors):
        lambda_handler({'led': color, 'state': 1}, None)
        print(f'Published: {color} - 1')
        sleep(.5)
        lambda_handler({'led': color, 'state': 0}, None)
        print(f'Published: {color} - 0')
