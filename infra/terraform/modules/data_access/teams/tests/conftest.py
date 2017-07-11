import copy
import json
import mock

import boto3
import pytest


TEST_BUCKET_REGION = "eu-west-1"
TEST_ENV = "test"
TEST_TEAM_SLUG = "__Justice____League--"
TEST_BUCKET_NAME = "{}-justice-league".format(TEST_ENV)
TEST_IAM_ARN_BASE = "arn:aws:iam::1234"
TEST_BUCKET_ARN = "arn:aws:s3:::{}".format(TEST_BUCKET_NAME)
TEST_ROLE_NAME = "test-role"
TEST_GROUP_NAME = "test-group"
TEST_USER_NAME = "test-user"
TEST_READONLY_POLICY_ARN = "{}:policy/{}-readonly".format(
    TEST_IAM_ARN_BASE, TEST_BUCKET_NAME)
TEST_READWRITE_POLICY_ARN = "{}:policy/{}-readwrite".format(
    TEST_IAM_ARN_BASE, TEST_BUCKET_NAME)
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
TEST_LOGS_PREFIX = "{}/".format(TEST_BUCKET_NAME)
TEST_LOGS_BUCKET_NAME = "test-logs"


@pytest.yield_fixture
def given_the_env_is_set():
    with mock.patch.dict("os.environ", {
        "BUCKET_REGION": TEST_BUCKET_REGION,
        "IAM_ARN_BASE": TEST_IAM_ARN_BASE,
        "ENV": TEST_ENV,
        "LOGS_BUCKET_NAME": TEST_LOGS_BUCKET_NAME,
    }):
        yield


@pytest.fixture
def iam_client_mock():
    client = mock.create_autospec(boto3.client("iam"))

    entities_for_policy = {
        "PolicyRoles": [{"RoleName": TEST_ROLE_NAME}],
        "PolicyGroups": [{"GroupName": TEST_GROUP_NAME}],
        "PolicyUsers": [{"UserName": TEST_USER_NAME}],
    }
    client.list_entities_for_policy = mock.Mock(
        return_value=entities_for_policy
    )

    return client


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
