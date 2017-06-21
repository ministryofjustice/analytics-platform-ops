'''
Environment variables:
 - STAGE, e.g. "dev", "alpha", etc...
'''

import os
import re


def role_name(username):
    return "{env}_user_{username}".format(
        env=os.environ["STAGE"],
        username=username.lower(),
    )


def bucket_name(slug):
    '''
    Generate the S3 bucket name by prefixing the environment name and
    replacing invalid characters with an hyphen ('-').

    NOTE: This is a very simple implementation which doesn't cover all the
          S3 limitations (e.g. max length or labels limitations, etc...)

    See: http://docs.aws.amazon.com/en_gb/AmazonS3/latest/dev/BucketRestrictions.html
    '''

    INVALID_BUCKET_CHARS = r"[^a-z0-9.-]+"

    name = slug.lower()
    name = re.sub(INVALID_BUCKET_CHARS, "-", name)
    name = name.strip("-")

    return "{}-{}".format(os.environ["STAGE"], name)


def policy_name(bucket_name, policy_type):
    return "{bucket_name}-{policy_type}".format(
        bucket_name=bucket_name,
        policy_type=policy_type,
    )

def policy_arn(iam_arn_base, bucket_name, policy_type):
    return "{iam_arn_base}:policy/{policy_name}".format(
        iam_arn_base=iam_arn_base,
        policy_name=policy_name(bucket_name, policy_type),
    )
