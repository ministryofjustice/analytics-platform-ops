import json
import os

import boto3


'''
Environment variables:
 - STAGE, e.g. "dev", "alpha", etc...
 - ACCOUNT_ID, AWS Account ID
'''


def create_user_role(event, context):
    """
    Creates the role for the given user

    event = {"username": "alice"}
    """
    trust_relationship = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "arn:aws:iam::{}:saml-provider/auth0".format(os.environ["ACCOUNT_ID"])
                },
                "Action": "sts:AssumeRoleWithSAML",
                "Condition": {
                    "StringEquals": {
                        "SAML:aud": "https://signin.aws.amazon.com/saml"
                    }
                }
            }
        ]
    }

    client = boto3.client("iam")
    client.create_role(
        RoleName=role_name(event["username"]),
        Path="/users/",
        AssumeRolePolicyDocument=json.dumps(trust_relationship),
    )


def delete_user_role(event, context):
    """
    Deletes the role for the given user

    event = {"username": "alice"}
    """
    client = boto3.client("iam")
    client.delete_role(
        RoleName=role_name(event["username"])
    )


def role_name(username):
    return "{env}_{username}_role".format(
        env=os.environ["STAGE"],
        username=username,
    )
