import codecs
import os
import datetime
import logging

import boto3
from botocore.client import Config
import s3_log_parser
import requests
from requests.auth import HTTPBasicAuth


LOG = logging.getLogger(__name__)
LOG.setLevel(os.environ.get('LOG_LEVEL', 'DEBUG'))

s3 = boto3.client('s3', config=Config(signature_version='s3v4'))

s3_parser = s3_log_parser.make_parser(
    '%BO %B %t %a %r %si %o %k "%R" %s %e %b %y %m %n '
    '"%{Referer}i" "%{User-Agent}i" %v')


def lambda_handler(event, context):
    LOG.debug('Event received: {}'.format(event))

    for record in event['Records']:
        log_file = log_file_s3_object(record)

        LOG.debug('Indexing log file: bucket={bucket}, key={key}'.format(
            bucket=record['s3']['bucket']['name'],
            key=record['s3']['object']['key']))

        add_elasticsearch_index(log_file)


def log_file_s3_object(record):
    return s3.get_object(
        Bucket=record['s3']['bucket']['name'],
        Key=record['s3']['object']['key'])


def add_elasticsearch_index(log_file):
    for line in log_lines(log_file):
        post_to_elasticsearch(parse_log_entry(line))


def log_lines(log_file):

    log_data = log_file['Body']._raw_stream
    reader = codecs.getreader('utf-8')(log_data)

    for line in reader:

        line = line.strip()

        if line:
            yield line


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
        'index_prefix': 's3logs',
        'doctype': 's3-access-log',
        'params': 'pipeline=s3logs-geoip'
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

    log = s3_parser(entry)

    log['time_received'] = log['time_received_utc_isoformat']

    for key, value in dict(log).items():

        if key.startswith('time_received_'):
            del log[key]

        elif value == '-':
            log[key] = None

    return log
