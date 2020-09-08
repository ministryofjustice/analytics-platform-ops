import gzip
import json
import os
import datetime
import logging
import ipaddress

import boto3
from botocore.client import Config
import certifi
from elasticsearch import Elasticsearch
import elasticsearch.helpers


LOG = logging.getLogger(__name__)
LOG.setLevel(os.environ.get('LOG_LEVEL', 'DEBUG'))

ca_certs = certifi.where()
s3 = boto3.client('s3', config=Config(signature_version='s3v4'))


def lambda_handler(event, context):
    LOG.debug('Received S3 event: {}'.format(event))

    config = elasticsearch_config(os.environ)

    for record in event['Records']:
        log_file = log_file_s3_object(record)
        add_elasticsearch_index(log_file, config)


def elasticsearch_config(env):
    defaults = {
        'scheme': 'http',
        'domain': 'localhost',
        'port': '9200',
        'index_prefix': 'cloudtrail',
        'doctype': 'cloudtrail-log'
    }

    return dict(defaults, **elasticsearch_env_vars(env))


def elasticsearch_env_vars(env):
    values = {}

    for key, value in env.items():

        if key.startswith('ES_'):
            key = key[3:].lower()
            values[key] = value

    return values


def log_file_s3_object(record):
    return gzip.decompress(s3.get_object(
        Bucket=record['s3']['bucket']['name'],
        Key=record['s3']['object']['key'])['Body'].read())


def add_elasticsearch_index(log_file, config):
    es = elasticsearch_connection(config)
    index = elasticsearch_index(config['index_prefix'])

    successful, errors = elasticsearch.helpers.bulk(
        es, add_to_index(log_entries(log_file), index))

    LOG.debug((
        'Elasticsearch response: {successful} succeeded. '
        'Errors: {errors}').format(successful=successful, errors=errors))


def elasticsearch_connection(config):

    return Elasticsearch(
        '{scheme}://{domain}:{port}'.format(**config),
        http_auth=(config['username'], config['password']),
        timeout=300,
        use_ssl=True,
        verify_certs=True,
        ca_certs=ca_certs)


def elasticsearch_index(prefix, today=None):

    if today is None:
        today = datetime.datetime.utcnow()

    return '{prefix}-{date:%Y.%m.%d}'.format(
        prefix=prefix,
        date=today)


def add_to_index(docs, index):
    for doc in docs:
        LOG.debug('Posting to elasticsearch: {}'.format(doc))

        yield {
            '_op_type': 'index',
            '_index': index,
            '_type': 'cloudtrail-log',
            'pipeline': pipeline(doc),
            '_source': doc
        }


def pipeline(doc):
    if is_ipaddress(doc.get('sourceIPAddress')):
        return 'cloudtrail-geoip'

    return None


def is_ipaddress(value):
    try:
        ipaddress.ip_address(value)

    except ValueError:
        return False

    return True


def log_entries(log_file):
    log_data = json.loads(log_file)

    for record in log_data['Records']:
        yield parse_log_entry(record)


def parse_log_entry(entry):
    LOG.debug('Parsing log entry: {}'.format(entry))

    return entry
