import json
from unittest.mock import patch

import boto3
from moto import mock_iam
import pytest


TEST_ACCOUNT_ID = "123456789012"
TEST_STAGE = "test"
TEST_USERNAME = "alice"


@pytest.fixture
def username():
    return TEST_USERNAME


@pytest.yield_fixture
def given_the_env_is_set():
    with patch.dict("os.environ", {
        "ACCOUNT_ID": TEST_ACCOUNT_ID,
        "STAGE": TEST_STAGE,
    }):
        yield


@pytest.fixture
def role_name():
    return "{env}_{username}_role".format(
        env=TEST_STAGE,
        username=TEST_USERNAME,
    )


@pytest.yield_fixture
def given_iam_is_available():
    with mock_iam():
        yield


@pytest.fixture
def given_the_role_exists(role_name):
    client = boto3.client("iam")
    client.create_role(
        RoleName=role_name,
        Path="/users/",
        AssumeRolePolicyDocument="a trust relationship policy",
    )
