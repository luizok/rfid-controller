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
    return res


if __name__ == '__main__':

    colors = ['blue', 'red', 'yellow', 'green']

    for color in cycle(colors):
        lambda_handler({'led': color, 'state': 1}, None)
        print(f'Published: {color} - 1')
        sleep(.5)
        lambda_handler({'led': color, 'state': 0}, None)
        print(f'Published: {color} - 0')
