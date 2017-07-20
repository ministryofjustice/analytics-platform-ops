'''
Environment variables:
 - BUCKET_REGION, region where bucket will be created, e.g. "eu-west-1"
 - IAM_ARN_BASE, e.g. "arn:aws:iam::1234"
 - ENV, e.g. "dev", "alpha", etc...
 - SENTRY_DSN, Sentry DSN
'''

import json
import logging
import os
import re

import boto3

import naming
import sentry


READ_ONLY = False
READ_WRITE = True

LOG = logging.getLogger(__name__)
LOG_LEVEL = os.environ.get("LOG_LEVEL", "DEBUG")
LOG.setLevel(LOG_LEVEL)


@sentry.report_exceptions
def create_team_bucket(event, context):
    """
    Creates the team's S3 bucket, with logging enabled

    event = {"team": {"slug": "justice-league"}}
    """

    name = naming.bucket_name(event["team"]["slug"])
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
    client.put_bucket_logging(
        Bucket=name,
        BucketLoggingStatus={
            'LoggingEnabled': {
                'TargetBucket': os.environ['LOGS_BUCKET_NAME'],
                'TargetPrefix': "{}/".format(name)
            }
        },
    )


@sentry.report_exceptions
def create_team_bucket_policies(event, context):
    """
    Creates the policies for the team S3 bucket:
      - a "readonly" policy and
      - a "readwrite" policy

    event = {"team": {"slug": "justice-league"}}
    """

    bucket = naming.bucket_name(event["team"]["slug"])

    create_policy(readwrite=READ_ONLY, bucket_name=bucket)
    create_policy(readwrite=READ_WRITE, bucket_name=bucket)


def create_policy(readwrite, bucket_name):
    policy_name = naming.policy_name(
        bucket_name=bucket_name,
        policy_type="readwrite" if readwrite else "readonly"
    )

    LOG.debug("Creating '{}' policy".format(policy_name))

    client = boto3.client("iam")
    client.create_policy(
        PolicyName=policy_name,
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


@sentry.report_exceptions
def delete_team_bucket_policies(event, context):
    """
    Deletes the IAM policies for the team S3 bucket ("*-readonly" and
    "*-readwrite")

    event = {"team": {"slug": "justice-league"}}
    """

    bucket = naming.bucket_name(event["team"]["slug"])

    delete_policy(bucket_name=bucket, policy_type="readonly")
    delete_policy(bucket_name=bucket, policy_type="readwrite")


def delete_policy(bucket_name, policy_type):
    '''
    Delete an IAM policy

    NOTE: The policy needs to be detached from every entity first
    SEE: https://docs.aws.amazon.com/de_de/IAM/latest/APIReference/API_DeletePolicy.html
    '''

    policy_arn = naming.policy_arn(
        iam_arn_base=os.environ["IAM_ARN_BASE"],
        bucket_name=bucket_name,
        policy_type=policy_type,
    )

    LOG.debug("Deleting '{}' policy".format(policy_arn))

    detach_policy_from_entities(policy_arn)

    client = boto3.client("iam")
    client.delete_policy(PolicyArn=policy_arn)


def detach_policy_from_entities(policy_arn):
    # Get all entities to which policy is attached
    # See:
    # http://boto3.readthedocs.io/en/latest/reference/services/iam.html#IAM.Client.list_entities_for_policy
    client = boto3.client("iam")
    entities = client.list_entities_for_policy(PolicyArn=policy_arn)

    LOG.debug("Policy is attached to: {}".format(json.dumps(entities)))

    for role in entities["PolicyRoles"]:
        detach_policy_from_role(policy_arn, role["RoleName"])

    for group in entities["PolicyGroups"]:
        detach_policy_from_group(policy_arn, group["GroupName"])

    for user in entities["PolicyUsers"]:
        detach_policy_from_user(policy_arn, user["UserName"])


def detach_policy_from_role(policy_arn, role_name):
    LOG.debug("Detaching policy '{}' from role '{}'".format(
        policy_arn, role_name
    ))
    client = boto3.client("iam")
    client.detach_role_policy(
        RoleName=role_name,
        PolicyArn=policy_arn,
    )


def detach_policy_from_group(policy_arn, group_name):
    LOG.debug("Detaching policy '{}' from group '{}'".format(
        policy_arn, group_name
    ))
    client = boto3.client("iam")
    client.detach_group_policy(
        GroupName=group_name,
        PolicyArn=policy_arn,
    )


def detach_policy_from_user(policy_arn, user_name):
    LOG.debug("Detaching policy '{}' from user '{}'".format(
        policy_arn, user_name
    ))
    client = boto3.client("iam")
    client.detach_user_policy(
        UserName=user_name,
        PolicyArn=policy_arn,
    )
