#!/usr/bin/env python
"""
Requires boto3 and click packages to be installed.

1) Create a new virtualenv (python3 -m venv my_venv).
2) Enable the virtualenv (my_venv/bin/activate).
3) Install the dependencies: (pip install boto3 click).
4) Run the command (--help will give you more information).

What does this script do?

Reads all the current buckets, ensures that versioning is switched on for those
that don't yet have it and sets the life cycle configuration to send
non-current versions of files to glacier storage after 30 days.

This script should only be run once, when the following PR lands in master in
the control panel:

https://github.com/ministryofjustice/analytics-platform-control-panel/pull/816

(From that moment on, all S3 buckets will be configured in this way by the
control panel, as a default.)

This script allows us to preview the potential changes and run the script on
a defined number of buckets at once.
"""
import os
import click
import logging
import sys
import boto3
import json
from botocore.exceptions import ClientError
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


def is_control_panel_bucket(name, bucket):
    """
    Returns a boolean indication to say if the referenced name/bucket is
    associated with the control panel app.

    They either start with the name "alpha-app-" or they have a tag of
    "buckettype" with the value "datawarehouse".

    See discussion here:

    https://github.com/ministryofjustice/analytics-platform-ops/pull/320#discussion_r433765261
    """
    is_valid = name.startswith("alpha-app-")
    if name.startswith("dev-"):
        # Ignore this since it's a bucket associated with the dev instance.
        is_valid = False
    elif not is_valid:
        try:
            tags = bucket.Tagging()
            tags.load()
            for obj in tags.tag_set:
                if (
                    obj["Key"] == "buckettype"
                    and obj["Value"] == "datawarehouse"
                ):
                    is_valid = True
                    break
        except ClientError as ex:
            if ex.response.get("Error", {}).get("Code") != "NoSuchTagSet":
                raise
            # It wasn't possible to get the bucket's tags.
            is_valid = False
    logger.info(f"{is_valid} - Bucket {name} is associated with CP")
    return is_valid


def get_bucket(name):
    """
    Return details of the named bucket (or none, if it isn't a bucket that's
    valid for the purposes of this script).
    """
    bucket_obj = boto3.resource("s3").Bucket(name)
    if is_control_panel_bucket(name, bucket_obj):
        versioning = bucket_obj.Versioning()
        try:
            lifecycle_conf = bucket_obj.LifecycleConfiguration()
            lifecycle = lifecycle_conf.rules
        except ClientError as ex:
            lifecycle = ""
        return {
            "bucket": bucket_obj,
            "versioning": versioning.status,
            "lifecycle": lifecycle,
        }
    return None


def get_buckets(number=0):
    """
    Returns a dictionary of data/objects about each bucket for the default AWS
    account. Keys are bucket names. Only buckets related to the control panel
    are returned.

    Return only the `number` of buckets. If `number = 0` (the default), return
    all available buckets.
    """
    result = {}
    click.echo("Getting S3 bucket details.")
    s3 = boto3.client("s3")
    bucket_metadata = s3.list_buckets()
    if number:
        buckets = bucket_metadata["Buckets"][:number]
    else:
        buckets = bucket_metadata["Buckets"]
    with click.progressbar(buckets, len(buckets)) as bucket_list:
        for bucket in bucket_list:
            name = bucket["Name"]
            bucket_metadata = get_bucket(name)
            if bucket_metadata:
                result[name] = bucket_metadata
    return result


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
@click.option("-n", "--number", required=False, type=int)
def list(number=0):
    """
    List n (or all, if not given) bucket details.
    """
    buckets = get_buckets(number)
    data = [("Name", "Versioned", "LifeCycle")]
    col_width = [0, 0, 0]
    rows = []
    for name, bucket in buckets.items():
        v = bucket["versioning"]
        l = bucket["lifecycle"]
        v = v if v else "Disabled"
        if l:
            l = json.dumps(l, indent=1)
        else:
            l = "None"
        data.append((name, v, l))
    for row in data:
        for i, info in enumerate(row):
            col_width[i] = min(max(len(info) + 2, col_width[i]), 48)
    dashes = tuple(("-" * (width - 1) for width in col_width))
    data.insert(1, dashes)
    click.echo(f"The status of the buckets:")
    for row in data:
        output = ""
        for i in range(3):
            output += row[i].ljust(col_width[i])
        if not VERBOSE:
            click.echo(output)
        logger.info(output)


@main.command()
@click.option("-n", "--name", required=False, type=str)
@click.option("-a", "--amount", required=False, type=int)
@click.option("-x", "--execute", is_flag=True)
def update(name="", amount=0, execute=False):
    """
    Update either the named bucket or amount number of buckets, or all, if not
    given all buckets. Use --execute to make the changes happen, or else a
    preview will take place.
    """
    if name:
        bucket_metadata = get_bucket(name)
        if bucket_metadata:
            bucket = bucket_metadata["bucket"]
            versioning = bucket_metadata["versioning"] == "Enabled"
            lifecycle = bucket_metadata["lifecycle"]
            update_bucket(name, bucket, versioning, lifecycle, execute)
    else:
        buckets = get_buckets(amount)
        for k, v in buckets.items():
            name = k
            bucket = v["bucket"]
            versioning = v["versioning"] == "Enabled"
            lifecycle = v["lifecycle"]
            update_bucket(name, bucket, versioning, lifecycle, execute)


def update_bucket(name, bucket, versioning, lifecycle, execute):
    """
    Update the bucket to the expected versioning and life-cycle settings.
    """
    msg = f"Working on {name}."
    logger.info(msg)
    if not VERBOSE:
        click.echo(f"Working on {name}.")
    # Add versioning if not already set.
    if not versioning:
        msg = f"Enabling versioning for {name}."
        logger.info(msg)
        if not VERBOSE:
            click.echo(msg)
        if execute:
            v = bucket.Versioning()
            v.enable()
            click.secho("OK", fg="green")
        else:
            click.secho("OK", fg="yellow")
    # Set life cycle rule to send non-current versions of files to glacier
    # storage after 30 days. Only do this is there is not already a life cycle,
    # otherwise warn the user.
    if lifecycle:
        click.secho(f"Lifecycle already exists for {name}.", fg="red")
    else:
        lifecycle_id = "lifecycle_configuration"
        msg = f"Setting lifecycle {lifecycle_id} for bucket {name}."
        logger.info(msg)
        if not VERBOSE:
            click.echo("\n\n" + msg)
        life_cycle = {
            "Rules": [
                {
                    "ID": lifecycle_id,
                    "Status": "Enabled",
                    "Prefix": "",
                    "NoncurrentVersionTransitions": [
                        {"NoncurrentDays": 30, "StorageClass": "GLACIER",},
                    ],
                },
            ]
        }
        msg = json.dumps(life_cycle)
        logger.info(msg)
        if not VERBOSE:
            click.echo(msg)
        if execute:
            lifecycle_conf = boto3.client(
                "s3"
            ).put_bucket_lifecycle_configuration(
                Bucket=name, LifecycleConfiguration=life_cycle
            )
            click.secho("OK", fg="green")
        else:
            click.secho("OK", fg="yellow")


if __name__ == "__main__":
    main()
