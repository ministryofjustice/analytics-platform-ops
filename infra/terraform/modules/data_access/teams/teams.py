'''
Environment variables:
 - BUCKET_REGION, region where bucket will be created, e.g. "eu-west-1"
 - STAGE, e.g. "dev", "alpha", etc...
'''

import json
import logging
import os

import boto3


READ_ONLY = False
READ_WRITE = True

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


def create_team_bucket_policies(event, context):
    """
    Creates the policies for the team S3 bucket:
      - a "readonly" policy and
      - a "readwrite" policy

    event = {"team": {"slug": "justice-league"}}
    """
    bucket = bucket_name(event["team"]["slug"])

    create_policy(readwrite=READ_ONLY, bucket_name=bucket)
    create_policy(readwrite=READ_WRITE, bucket_name=bucket)


def create_policy(readwrite, bucket_name):
    policy_name = "{bucket_name}-{suffix}".format(
        bucket_name=bucket_name,
        suffix="readwrite" if readwrite else "readonly"
    )

    LOG.debug("Creating '{}' policy".format(policy_name))

    client = boto3.client("iam")
    client.create_policy(
        PolicyName=policy_name,
        Path="/teams/",
        PolicyDocument=json.dumps(get_policy_document(bucket_name, readwrite)),
    )


def get_policy_document(bucket_name, readwrite):
    bucket_arn = "arn:aws:s3:::{}".format(bucket_name)

    statements = [
        {
            "Sid": "ListBucketsInConsole",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Sid": "ListObjects",
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [bucket_arn],
        },
        {
            "Sid": "ReadObjects",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectVersion",
            ],
            "Effect": "Allow",
            "Resource": "{}/*".format(bucket_arn)
        },
    ]

    if readwrite:
        statements.append(
            {
                "Sid": "UpdateRenameAndDeleteObjects",
                "Action": [
                    "s3:DeleteObject",
                    "s3:DeleteObjectVersion",
                    "s3:PutObject",
                    "s3:PutObjectAcl",
                    "s3:RestoreObject",
                ],
                "Effect": "Allow",
                "Resource": "{}/*".format(bucket_arn)
            }
        )

    return {
        "Version": "2012-10-17",
        "Statement": statements,
    }


def bucket_name(slug):
    return "{}-{}".format(os.environ["STAGE"], slug)
