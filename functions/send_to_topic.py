from itertools import cycle
import json
import os
from time import sleep

import boto3


def lambda_handler(payload, context):

    topic_name = os.getenv('TOPIC_NAME')
    print(payload)

    res = boto3.client('iot-data').publish(
        topic=topic_name,
        payload=json.dumps(payload)
    )

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
