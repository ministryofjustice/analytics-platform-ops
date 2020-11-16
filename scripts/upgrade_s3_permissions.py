#!/usr/bin/env python
"""
Requires boto3 and click packages to be installed.

1) Create a new virtualenv (python3 -m venv my_venv).
2) Enable the virtualenv (my_venv/bin/activate).
3) Install the dependencies: (pip install boto3 click).
4) Run the command (--help will give you more information).

What does this script do?

This script ensures that every user (or a named user) has the expected
permissions for working with versioned S3 buckets.
"""
import os
import click
import logging
import sys
import boto3
from botocore.exceptions import ClientError
import json
from pathlib import Path


READ_ACTION = [
    "s3:GetObject",
    "s3:GetObjectAcl",
    "s3:GetObjectVersion",
    "s3:GetObjectVersionAcl",
    "s3:GetObjectVersionTagging"
]

WRITE_ACTION = [
    "s3:DeleteObject",
    "s3:DeleteObjectVersion",
    "s3:PutObject",
    "s3:PutObjectAcl",
    "s3:RestoreObject",
]

READWRITE_ACTION = READ_ACTION + WRITE_ACTION

LIST_ACTION = [
    "s3:ListBucket",
    "s3:GetBucketPublicAccessBlock",
    "s3:GetBucketPolicyStatus",
    "s3:GetBucketTagging",
    "s3:GetBucketPolicy",
    "s3:GetBucketAcl",
    "s3:GetBucketCORS",
    "s3:GetBucketVersioning",
    "s3:GetBucketLocation",
    "s3:ListBucketVersions"
]

LISTUSERBUCKETS_SECTION = {
    "Sid": "ListUserBuckets",
    "Effect": "Allow",
    "Action": [
        "s3:ListAllMyBuckets",
        "s3:ListAccessPoints",
        "s3:GetAccountPublicAccessBlock"
    ],
    "Resource": "*"
}


# Setup logging. Logs will appear in user's home directory.
LOGFILE = os.path.join(str(Path.home()), "bucket_update.log")
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logfile_handler = logging.FileHandler(LOGFILE)
log_formatter = logging.Formatter("%(levelname)s: %(message)s")
logfile_handler.setFormatter(log_formatter)
logger.addHandler(logfile_handler)


@click.group()
@click.option(
    "--verbose", is_flag=True, help="Comprehensive logging set to stdout."
)
def main(verbose=False):
    """
    A tool to manage the versioning and life cycle of S3 buckets.
    """
    if verbose:
        verbose_handler = logging.StreamHandler(sys.stdout)
        verbose_handler.setLevel(logging.INFO)
        verbose_handler.setFormatter(log_formatter)
        logger.addHandler(verbose_handler)
    click.echo("Logging to {}\n".format(LOGFILE))


@main.command()
@click.option("-n", "--username", required=False, type=str)
@click.option("-x", "--execute", is_flag=True)
def update(username="", execute=False):
    """
    Command entry point.

    Update either the named user with the new S3 related permissions.
    """
    if username:
        # Just update a specific user (for testing purposes).
        rolename = f"alpha_user_{username}"
        update_user(rolename, execute)
    else:
        # Grab all users and iterate.
        iam_client = boto3.client('iam')
        paginator = iam_client.get_paginator('list_roles')
        rolenames = set()
        for response in paginator.paginate():
            for role in response["Roles"]:
                rolename = role["RoleName"]
                if (
                       rolename.startswith("dev_user_") or
                       rolename.startswith("alpha_user_")
                   ):
                    rolenames.add(rolename)
        for rolename in rolenames:
            update_user(rolename, execute)


def update_user(rolename, execute=False):
    """
    Update the policy for the given role. Make changes if execute flag is True.
    """
    msg = f"Working on {rolename}."
    logger.info(msg)
    click.echo(msg)

    iam_client = boto3.client('iam')
    try:
        policy_document = iam_client.get_role_policy(RoleName=rolename,
                                              PolicyName='s3-access')
    except ClientError as ex:
        logger.info(ex)
        click.secho(str(ex), fg="red")
        return  # No more to do.

    new_statements = []
    for statement in policy_document["PolicyDocument"]["Statement"]:
        # Update the "Action" list depending on the statement ID (Sid).
        sid = statement["Sid"]
        if sid == "console":
            statement = LISTUSERBUCKETS_SECTION 
        elif sid == "readonly":
            statement["Action"] = READ_ACTION
        elif sid == "readwrite":
            statement["Action"] = READWRITE_ACTION
        elif sid == "list":
            statement["Action"] = LIST_ACTION
        new_statements.append(statement)
    policy_document["PolicyDocument"]["Statement"] = new_statements

    logger.info(policy_document)
    if execute:
        # POST the update.
        response = iam_client.put_role_policy(
            RoleName=rolename,
            PolicyName='s3-access',
            PolicyDocument=json.dumps(policy_document["PolicyDocument"])
        )
        click.secho("OK", fg="green")
    else:
        click.secho("Skipped", fg="yellow")


if __name__ == "__main__":
    main()
