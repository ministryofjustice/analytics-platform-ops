import json
import os

import boto3


'''
Environment variables:
 - STAGE, e.g. "dev", "alpha", etc...
 - SAML_PROVIDER_ARN, SAML provider used to login
'''


def create_user_role(event, context):
    """
    Creates the role for the given user

    event = {"username": "alice"}
    """

    # See: `sts:AssumeRole` required by kube2iam
    # https://github.com/jtblin/kube2iam#iam-roles
    trust_relationship = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": os.environ["SAML_PROVIDER_ARN"],
                },
                "Action": "sts:AssumeRoleWithSAML",
                "Condition": {
                    "StringEquals": {
                        "SAML:aud": "https://signin.aws.amazon.com/saml"
                    }
                }
            },
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            },
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": os.environ["K8S_WORKER_ROLE_ARN"]
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }

    client = boto3.client("iam")
    client.create_role(
        RoleName=role_name(event["username"]),
        AssumeRolePolicyDocument=json.dumps(trust_relationship),
    )


def delete_user_role(event, context):
    """
    Deletes the role for the given user

    event = {"username": "alice"}
    """
    name = role_name(event["username"])

    detach_role_policies(name)

    client = boto3.client("iam")
    client.delete_role(RoleName=name)


def detach_role_policies(role_name):
    client = boto3.client("iam")

    policies = client.list_attached_role_policies(RoleName=role_name)
    for policy in policies["AttachedPolicies"]:
        client.detach_role_policy(
            RoleName=role_name,
            PolicyArn=policy["PolicyArn"],
        )


def role_name(username):
    return "{env}_user_{username}".format(
        env=os.environ["STAGE"],
        username=username.lower(),
    )
