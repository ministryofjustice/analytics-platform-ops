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


# A flag to indicate if the command is to be run in verbose mode.
VERBOSE = False


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
        global VERBOSE
        VERBOSE = True
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
                       rolename.startswith("alpha_user_"
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
    if not VERBOSE:
        click.echo(msg)

    iam_client = boto3.client('iam')
    try:
        policy_document = iam_client.get_role_policy(RoleName=rolename,
                                              PolicyName='s3-access')
    except ClientError as ex:
        logger.info(ex)
        if not VERBOSE:
            click.secho(str(ex), fg="red")
        return  # No more to do.

    # Grab the relevant action IF the permission isn't already there.
    action = [action for action in
                  policy_document["PolicyDocument"]["Statement"]
              if
                  "s3:ListAllMyBuckets" in action["Action"] and
                  "s3:ListBucketVersions" not in action["Action"]]
    if action:
        action = action[0]
        # Add the required permission.
        action["Action"].append("s3:ListBucketVersions")
        logger.info(policy_document)
        if execute:
            # POST the update.
            response = iam_client.put_role_policy(
                RoleName=rolename,
                PolicyName='s3-access',
                PolicyDocument=json.dumps(policy_document["PolicyDocument"])
            )
            msg = "OK"
            logger.info(msg)
            if not VERBOSE:
                click.secho(msg, fg="green")


if __name__ == "__main__":
    main()
