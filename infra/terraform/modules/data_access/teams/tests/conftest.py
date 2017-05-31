import json
import mock

import boto3
import pytest


TEST_BUCKET_REGION = "eu-west-1"
TEST_STAGE = "test"
TEST_TEAM_SLUG = "justice-league"
TEST_BUCKET_NAME = "{}-{}".format(TEST_STAGE, TEST_TEAM_SLUG)


@pytest.yield_fixture
def given_the_env_is_set():
    with mock.patch.dict("os.environ", {
        "BUCKET_REGION": TEST_BUCKET_REGION,
        "STAGE": TEST_STAGE,
    }):
        yield


@pytest.fixture
def s3_client_mock():
    return mock.create_autospec(boto3.client("s3"))


@pytest.yield_fixture
def given_s3_is_available(s3_client_mock):
    with mock.patch.object(boto3, "client", return_value=s3_client_mock):
        yield
