import os
import datetime
import logging

import boto3
from botocore.client import Config
import s3_log_parser
import requests
from requests.auth import HTTPBasicAuth

LOG = logging.getLogger(__name__)
LOG_LEVEL = os.environ.get("LOG_LEVEL", "DEBUG")
LOG.setLevel(LOG_LEVEL)

ES_URL = '{scheme}://{domain}:{port}/{index}/{doctype}'.format(**{
    'domain': os.environ.get('ES_DOMAIN', 'localhost'),
    'port': os.environ.get('ES_PORT', '9200'),
    'scheme': os.environ.get('ES_SCHEME', 'http'),
    'doctype': os.environ.get('ES_DOCTYPE', 's3-access-log'),
    'index': "-".join([
        os.environ.get('ES_INDEX_PREFIX', 's3logs'),
        datetime.datetime.utcnow().strftime('%Y.%m.%d')])
})
ES_USERNAME = os.environ.get('ES_USERNAME', None)
ES_PASSWORD = os.environ.get('ES_PASSWORD', None)

s3 = boto3.client('s3', config=Config(signature_version='s3v4'))
s3_parser = s3_log_parser.make_parser(
    "%BO %B %t %a %r %si %o %k \"%R\" %s %e %b %y %m %n "
    "\"%{Referer}i\" \"%{User-Agent}i\" %v")


def lambda_handler(event, context):
    LOG.debug('Event received: {}'.format(event))

    for record in event['Records']:
        process_log_file(
            record['s3']['bucket']['name'],
            record['s3']['object']['key'])


def process_log_file(bucket, key):
    LOG.debug('Processing log file: bucket={}, key={}'.format(bucket, key))

    obj = s3.get_object(Bucket=bucket, Key=key)
    log_file = obj['Body'].read().decode('utf-8')

    for line in log_file.split('\n'):
        if line:
            post_to_es(parse_log_entry(line))


def parse_log_entry(entry):
    LOG.debug('Parsing log entry: {}'.format(entry))

    log = s3_parser(entry)

    # Use ISO-formatted UTC datetime for time_received field
    log['time_received'] = log['time_received_utc_isoformat']

    # Strip out all other time_received variant fields
    log = {k: v for k, v in log.items() if not k.startswith('time_received_')}

    # Convert '-' null values to None
    log = {k: v if v != '-' else None for k, v in log.items()}

    LOG.debug('Parsed log entry: {}'.format(log))

    return log


def post_to_es(doc):
    LOG.debug('Posting to elasticsearch: {}'.format(doc))

    url = '{}?pipeline=s3logs-geoip'.format(ES_URL)
    r = requests.post(
        url, auth=HTTPBasicAuth(ES_USERNAME, ES_PASSWORD), json=doc)

    LOG.debug('ES status code: {}'.format(r.status_code))
    LOG.debug('ES response msg: {}'.format(r.text))
