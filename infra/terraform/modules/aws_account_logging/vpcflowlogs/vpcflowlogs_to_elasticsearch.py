import datetime
import gzip
import logging
import os
from itertools import islice
import boto3
import certifi
import elasticsearch.helpers
import jsonpickle
from elasticsearch import Elasticsearch
from flowlogs_reader import FlowRecord

LOG = logging.getLogger(__name__)
LOG.setLevel(os.environ.get('LOG_LEVEL', 'DEBUG'))

creds = os.environ['ES_USERNAME'] + ':' + os.environ['ES_PASSWORD']

es = Elasticsearch(
    host=os.environ['ES_DOMAIN'],
    port=os.environ['ES_PORT'],
    http_auth=creds,
    use_ssl=True,
    verify_certs=True,
    ca_certs=certifi.where(),
    timeout=120
)

index = 'flow-log'
index_type = 'lambda-type'

s3 = boto3.client('s3')


# Lambda execution starts here
def lambda_handler(event, context):
    for record in event['Records']:

        # Get the bucket name and key for the new file
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        # Get, read, and split the file into lines
        obj = s3.get_object(Bucket=bucket, Key=key)
        body = gzip.decompress(obj['Body'].read())
        lines = body.decode('UTF-8').splitlines()

        # Post logs to elasticsearch
        elasticsearch.helpers.bulk(es, log_data(lines), index=index)


# Convert each log line to JSON
def log_data(lines):
    # Skip heading line in log file
    for line in islice(lines, 1, None):

        # Marshal log event to slot\dictionary
        line_dict = FlowRecord.from_message(line)

        # Marshal log event to JSON and strip python metadata
        document = jsonpickle.encode(line_dict, unpicklable=False)

        yield {
            '_op_type': 'index',
            '_index': elasticsearch_index(index),
            '_type': index_type,
            'timestamp': line_dict.start,
            '_source': document,
        }


# Set index name format flow-log-yyyy.mm.dd
def elasticsearch_index(prefix, today=None):
    if today is None:
        today = datetime.datetime.utcnow()

    return '{prefix}-{date:%Y.%m.%d}'.format(
        prefix=prefix,
        date=today)
