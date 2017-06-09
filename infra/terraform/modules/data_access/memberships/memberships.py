
'''
Environment variables:
 - STAGE, e.g. "dev", "alpha", etc...
 - IAM_ARN_BASE, e.g. "arn:aws:iam::1234"
'''


import json
import os

import boto3


POLICY_READ_ONLY = "readonly"
POLICY_READ_WRITE = "readwrite"


class InvalidPolicyType(Exception):
    pass


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
    if not policy_type in [POLICY_READ_ONLY, POLICY_READ_WRITE]:
        raise InvalidPolicyType("type can only be '{}' or '{}'".format(
            POLICY_READ_ONLY, POLICY_READ_WRITE))

    username = event["user"]["username"]
    team_slug = event["team"]["slug"]

    client = boto3.client("iam")
    client.attach_role_policy(
        RoleName=role_name(username),
        PolicyArn=policy_arn(team_slug, policy_type),
    )


def role_name(username):
    return "{env}_{username}".format(
        env=os.environ["STAGE"],
        username=username,
    )


def policy_arn(team_slug, policy_type):
    policy_name = "{bucket_name}-{policy_type}".format(
        bucket_name=bucket_name(team_slug),
        policy_type=policy_type,
    )

    return "{iam_arn_base}:policy/teams/{policy_name}".format(
        iam_arn_base=os.environ["IAM_ARN_BASE"],
        policy_name=policy_name,
    )


def bucket_name(team_slug):
    return "{env}-{team_slug}".format(
        env=os.environ["STAGE"],
        team_slug=team_slug
    )
