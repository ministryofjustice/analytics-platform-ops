
'''
Environment variables:
 - STAGE, e.g. "dev", "alpha", etc...
 - IAM_ARN_BASE, e.g. "arn:aws:iam::1234"
 - LOG_LEVEL, change the logging level (default is "DEBUG"). Must be one of
   the python logging supported levels: "CRITICAL", "ERROR", "WARNING",
   "INFO" or "DEBUG" (See: https://docs.python.org/2/library/logging.html#logging-levels)
'''


import json
import logging
import os
import re

import boto3
import botocore.exceptions

import naming
import sentry


POLICY_READ_ONLY = "readonly"
POLICY_READ_WRITE = "readwrite"

LOG = logging.getLogger(__name__)
LOG_LEVEL = os.environ.get("LOG_LEVEL", "DEBUG")
LOG.setLevel(LOG_LEVEL)


class InvalidPolicyType(Exception):
    pass


@sentry.catch_exceptions
def attach_bucket_policy(event, context):
    """
    Attaches the team bucket IAM policy to the user's IAM role

    event = {
        "user": {"username": "alice"},
        "team": {"slug": "justice-league"},
        "policy": {"type": "readwrite"},
    }
    """

    policy_type = event["policy"]["type"]
    validate_policy_type(policy_type)

    username = event["user"]["username"]
    team_slug = event["team"]["slug"]

    client = boto3.client("iam")
    client.attach_role_policy(
        RoleName=naming.role_name(username),
        PolicyArn=policy_arn(team_slug, policy_type),
    )


@sentry.catch_exceptions
def detach_bucket_policies(event, context):
    """
    Detaches the team bucket IAM policies from the user's IAM role

    event = {
        "user": {"username": "alice"},
        "team": {"slug": "justice-league"}
    }
    """

    username = event["user"]["username"]
    team_slug = event["team"]["slug"]

    client = boto3.client("iam")
    errors = []
    for policy_type in [POLICY_READ_WRITE, POLICY_READ_ONLY]:
        # Be sure we detach all policies without stopping early
        try:
            client.detach_role_policy(
                RoleName=naming.role_name(username),
                PolicyArn=policy_arn(team_slug, policy_type),
            )
        except botocore.exceptions.ClientError as error:
            # Ignoring this error raised when detaching a policy not attached
            if error.response["Error"]["Code"] != "NoSuchEntity":
                errors.append(error)
        except Exception as error:
            # Other exceptions are saved and raised after the loop
            errors.append(error)

    if errors:
        message = "One or more errors occurred while detaching policies from role: {}".format(
            errors)
        LOG.error(message)
        raise Exception(message)


def validate_policy_type(policy_type):
    if not policy_type in [POLICY_READ_ONLY, POLICY_READ_WRITE]:
        raise InvalidPolicyType("type can only be '{}' or '{}'".format(
            POLICY_READ_ONLY, POLICY_READ_WRITE))


def policy_arn(team_slug, policy_type):
    return naming.policy_arn(
        iam_arn_base=os.environ["IAM_ARN_BASE"],
        bucket_name=naming.bucket_name(team_slug),
        policy_type=policy_type,
    )
