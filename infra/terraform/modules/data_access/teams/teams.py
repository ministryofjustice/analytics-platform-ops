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


def create_team_bucket_policies(event, context):
    """
    Creates the policies for the team S3 bucket:
      - a "readonly" policy and
      - a "readwrite" policy

    event = {"team": {"slug": "justice-league"}}
    """
    bucket = bucket_name(event["team"]["slug"])

    create_policy(
        name="{}-readonly".format(bucket),
        bucket=bucket,
        readwrite=False,
    )

    create_policy(
        name="{}-readwrite".format(bucket),
        bucket=bucket,
        readwrite=True,
    )


def create_policy(name, bucket, readwrite):
    LOG.debug("Creating '{}' policy".format(name))

    policy_document = get_policy_document(bucket, readwrite)

    client = boto3.client("iam")
    client.create_policy(
        PolicyName=name,
        Path="/teams/",
        PolicyDocument=json.dumps(policy_document),
    )


def get_policy_document(bucket, readwrite):
    bucket_arn = "arn:aws:s3:::{}".format(bucket)

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
