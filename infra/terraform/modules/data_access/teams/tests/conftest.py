import copy
import json
import mock

import boto3
import pytest


TEST_BUCKET_REGION = "eu-west-1"
TEST_STAGE = "test"
TEST_TEAM_SLUG = "justice-league"
TEST_BUCKET_NAME = "{}-{}".format(TEST_STAGE, TEST_TEAM_SLUG)
TEST_BUCKET_ARN = "arn:aws:s3:::{}".format(TEST_BUCKET_NAME)
TEST_READONLY_POLICY_DOCUMENT = {
    "Version": "2012-10-17",
    "Statement": [
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
            "Resource": [TEST_BUCKET_ARN],
        },
        {
            "Sid": "ReadObjects",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectVersion",
            ],
            "Effect": "Allow",
            "Resource": "{}/*".format(TEST_BUCKET_ARN)
        },
    ],
}
TEST_READWRITE_POLICY_DOCUMENT = copy.deepcopy(TEST_READONLY_POLICY_DOCUMENT)
TEST_READWRITE_POLICY_DOCUMENT["Statement"].append(
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
        "Resource": "{}/*".format(TEST_BUCKET_ARN)
    }
)


@pytest.yield_fixture
def given_the_env_is_set():
    with mock.patch.dict("os.environ", {
        "BUCKET_REGION": TEST_BUCKET_REGION,
        "STAGE": TEST_STAGE,
    }):
        yield


@pytest.fixture
def iam_client_mock():
    return mock.create_autospec(boto3.client("iam"))


@pytest.fixture
def s3_client_mock():
    return mock.create_autospec(boto3.client("s3"))


@pytest.yield_fixture
def given_iam_is_available(iam_client_mock):
    with mock.patch.object(boto3, "client", return_value=iam_client_mock):
        yield


@pytest.yield_fixture
def given_s3_is_available(s3_client_mock):
    with mock.patch.object(boto3, "client", return_value=s3_client_mock):
        yield
