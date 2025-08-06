import http.client
from itertools import cycle
import hashlib
import json
import os
from time import sleep
from urllib.parse import urlparse

import boto3


def split_url(url):
    parsed = urlparse(url)
    host = parsed.netloc
    path = parsed.path or "/"

    return host, path


def get_last_hash(callback_url, retries=3, delay=.5):
    attempt = 0

    host, path = split_url(callback_url)

    while attempt < retries:
        try:
            print(f"Tentativa {attempt + 1} de {retries}...")
            conn = http.client.HTTPSConnection(host, timeout=2)
            conn.request("GET", path)
            response = conn.getresponse()
            data = response.read().decode("utf-8")
            conn.close()

            if 200 <= response.status < 300:
                last_hash = json.loads(data)['hash']
                return last_hash

            raise Exception(f"Erro HTTP {response.status}")

        except Exception as e:
            print(f"Erro: {e}")
            attempt += 1
            if attempt < retries:
                print(f"Aguardando {delay} segundos para nova tentativa...")
                sleep(delay)
            else:
                print("Máximo de tentativas atingido. Falha na requisição.")
                return None


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

    assert res['ResponseMetadata']['HTTPStatusCode'] == 200

    count = 1
    max_tries = 3
    while count <= max_tries:
        last_hash = get_last_hash(payload['callbackUrl'])
        if last_hash == hash_md5:
            return {
                "statusCode": 200,
                "contentType": "application/json",
                "body": json.dumps({
                    "message": f'Request Id {last_hash} succeeded'
                })
            }
        sleep(.5)

    return {
        "statusCode": 500,
        "contentType": "application/json",
        "body": json.dumps({
            "message": 'Request Id {last_hash} was unable to complete'
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
