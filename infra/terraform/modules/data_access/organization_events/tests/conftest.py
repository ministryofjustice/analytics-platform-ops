import json
import mock

import boto3
import pytest


TEST_CREATE_ROLE_ARN = "arn:aws:iam::123456789012:lambda/create_role"
TEST_DELETE_ROLE_ARN = "arn:aws:iam::123456789012:lambda/delete_role"
TEST_USERNAME = "alice"
TEST_PAYLOAD = {"username": TEST_USERNAME}
TEST_PAYLOAD_BYTES = json.dumps(TEST_PAYLOAD).encode("utf8")


@pytest.yield_fixture
def given_the_env_is_set():
    with mock.patch.dict("os.environ", {
        "LAMBDA_CREATE_ROLE_ARN": TEST_CREATE_ROLE_ARN,
        "LAMBDA_DELETE_ROLE_ARN": TEST_DELETE_ROLE_ARN,
    }):
        yield


@pytest.fixture
def lambda_client_mock():
    return mock.create_autospec(boto3.client("lambda"))


@pytest.yield_fixture
def given_lambda_is_available(lambda_client_mock):
    with mock.patch.object(boto3, "client", return_value=lambda_client_mock):
        yield


def sns_event(action):
    github_event = {
        "action": action,
        "membership": {
            "user": {
                "login": TEST_USERNAME,
            }
        }
    }

    return {
        "Records": [
            {
                "Sns": {
                    "Message": json.dumps(github_event),
                }
            }
        ]
    }
