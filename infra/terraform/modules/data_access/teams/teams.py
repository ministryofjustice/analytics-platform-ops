'''
Environment variables:
 - BUCKET_REGION, region where bucket will be created, e.g. "eu-west-1"
 - STAGE, e.g. "dev", "alpha", etc...
'''

import json
import logging
import os

import boto3


LOG = logging.getLogger(__name__)
LOG_LEVEL = os.environ.get("LOG_LEVEL", "DEBUG")
LOG.setLevel(LOG_LEVEL)


def create_team_bucket(event, context):
    """
    Creates the team's S3 bucket

    event = {"team": {"slug": "justice-league"}}
    """
    name = bucket_name(event["team"]["slug"])
    region = os.environ["BUCKET_REGION"]

    LOG.debug("Creating S3 bucket '{name}' (private) in region '{region}'".format(
        name=name,
        region=region,
    ))

    client = boto3.client("s3")
    client.create_bucket(
        Bucket=name,
        ACL="private",
        CreateBucketConfiguration={"LocationConstraint": region},
    )


def bucket_name(slug):
    return "{}-{}".format(os.environ["STAGE"], slug)
