import json
import mock

import boto3
import pytest


TEST_ATTACH_BUCKET_POLICY_ARN = "arn:aws:iam::123456789012:lambda/attach_bucket_policy"
TEST_DETACH_BUCKET_POLICY_ARN = "arn:aws:iam::123456789012:lambda/detach_bucket_policy"
TEST_USERNAME = "alice"
TEST_TEAM_SLUG = "justice-league"

TEST_PAYLOAD = {
    "user": {"username": TEST_USERNAME},
    "team": {"slug": TEST_TEAM_SLUG},
    "policy": {"type": "readwrite"},
}
TEST_PAYLOAD_BYTES = json.dumps(TEST_PAYLOAD).encode("utf8")


@pytest.yield_fixture
def given_the_env_is_set():
    with mock.patch.dict("os.environ", {
        "LAMBDA_ATTACH_BUCKET_POLICY_ARN": TEST_ATTACH_BUCKET_POLICY_ARN,
        "LAMBDA_DETACH_BUCKET_POLICY_ARN": TEST_DETACH_BUCKET_POLICY_ARN,
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
        "scope": "team",
        "action": action,
        "member": {
            "login": TEST_USERNAME,
        },
        "team": {
            "slug": TEST_TEAM_SLUG,
        },
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
