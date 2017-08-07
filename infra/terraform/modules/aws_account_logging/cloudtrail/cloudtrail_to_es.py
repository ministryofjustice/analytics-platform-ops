import gzip
import json
import os
import datetime
import logging

import boto3
from botocore.client import Config
import requests
from requests.auth import HTTPBasicAuth


LOG = logging.getLogger(__name__)
LOG.setLevel(os.environ.get('LOG_LEVEL', 'DEBUG'))

s3 = boto3.client('s3', config=Config(signature_version='s3v4'))


def lambda_handler(event, context):

    for record in event['Records']:
        log_file = log_file_s3_object(record)
        add_elasticsearch_index(log_file)


def log_file_s3_object(record):
    return gzip.decompress(s3.get_object(
        Bucket=record['s3']['bucket']['name'],
        Key=record['s3']['object']['key'])['Body'].read())


def add_elasticsearch_index(log_file):
    for entry in log_entries(log_file):
        post_to_elasticsearch(parse_log_entry(entry))


def log_entries(log_file):

    log_data = json.loads(log_file)

    for record in log_data['Records']:
        yield record


def post_to_elasticsearch(doc):
    LOG.debug('Posting to elasticsearch: {}'.format(doc))

    # TODO handle errors
    response = requests.post(
        elasticsearch_url(os.environ),
        auth=elasticsearch_auth_header(os.environ),
        json=doc)

    LOG.debug('Elasticsearch response: {status} - {text}'.format(
        status=response.status_code,
        text=response.text))


def elasticsearch_url(env):

    values = {
        'scheme': 'http',
        'domain': 'localhost',
        'port': '9200',
        'index_prefix': 'logstash-cloudtrail',
        'doctype': 'cloudtrail-log',
        'params': 'pipeline=logstash-cloudtrail'
    }

    values.update(elasticsearch_env_vars(env))

    return '{scheme}://{domain}:{port}/{index}/{doctype}?{params}'.format(
        index=elasticsearch_url_index(values['index_prefix']),
        **values)


def elasticsearch_env_vars(env):
    values = {}

    for key, value in env.items():

        if key.startswith('ES_'):
            key = key[3:].lower()
            values[key] = value

    return values


def elasticsearch_url_index(prefix, today=None):

    if today is None:
        today = datetime.datetime.utcnow()

    return '{prefix}-{date:%Y.%m.%d}'.format(
        prefix=prefix,
        date=today)


def elasticsearch_auth_header(env):
    return HTTPBasicAuth(
        env.get('ES_USERNAME'),
        env.get('ES_PASSWORD'))


def parse_log_entry(entry):

    LOG.debug('Parsing log entry: {}'.format(entry))

    return entry
