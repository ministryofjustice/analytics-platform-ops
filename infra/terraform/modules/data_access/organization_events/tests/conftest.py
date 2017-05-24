import json
import mock

import boto3
import pytest


TEST_CREATE_ROLE_ARN = "arn:aws:iam::123456789012:lambda/create_role"
TEST_DELETE_ROLE_ARN = "arn:aws:iam::123456789012:lambda/delete_role"
TEST_USERNAME = "alice"


@pytest.yield_fixture
def given_the_env_is_set():
    with mock.patch.dict("os.environ", {
        "CREATE_ROLE_ARN": TEST_CREATE_ROLE_ARN,
        "DELETE_ROLE_ARN": TEST_DELETE_ROLE_ARN,
    }):
        yield


@pytest.fixture
def payload_bytes():
    return bytes(
        json.dumps({"username": TEST_USERNAME}),
        "utf8"
    )


@pytest.fixture
def lambda_client_mock():
    return mock.create_autospec(boto3.client("lambda"))


@pytest.yield_fixture
def given_lambda_is_available(lambda_client_mock):
    with mock.patch.object(boto3, "client", return_value=lambda_client_mock):
        yield


@pytest.fixture
def member_added_event():
    return sns_event(
        github_event("member_added", TEST_USERNAME)
    )


@pytest.fixture
def member_removed_event():
    return sns_event(
        github_event("member_removed", TEST_USERNAME)
    )


def github_event(action, username):
    return {
        "action": action,
        "membership": {
            "user": {
                "login": TEST_USERNAME,
            }
        }
    }


def sns_event(github_event):
    return {
        "Records": [
            {
                "Sns": {
                    "Message": json.dumps(github_event),
                }
            }
        ]
    }


@pytest.fixture
def create_role_arn():
    return TEST_CREATE_ROLE_ARN


@pytest.fixture
def delete_role_arn():
    return TEST_DELETE_ROLE_ARN
