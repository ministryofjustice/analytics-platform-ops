import json
import mock

import boto3
import pytest


TEST_LAMBDA_CREATE_TEAM_BUCKET_ARN = "arn:aws:iam::123456789012:lambda/create_team_bucket"
TEST_LAMBDA_CREATE_TEAM_BUCKET_POLICIES_ARN = "arn:aws:iam::123456789012:lambda/create_team_bucket_policies"
TEST_LAMBDA_DELETE_TEAM_BUCKET_POLICIES_ARN = "arn:aws:iam::123456789012:lambda/delete_team_bucket_policies"
TEST_TEAM_SLUG = "occupear"
TEST_PAYLOAD = {"team": {"slug": TEST_TEAM_SLUG}}
TEST_PAYLOAD_BYTES = json.dumps(TEST_PAYLOAD).encode("utf8")


@pytest.yield_fixture
def given_the_env_is_set():
    with mock.patch.dict("os.environ", {
        "LAMBDA_CREATE_TEAM_BUCKET_ARN": TEST_LAMBDA_CREATE_TEAM_BUCKET_ARN,
        "LAMBDA_CREATE_TEAM_BUCKET_POLICIES_ARN": TEST_LAMBDA_CREATE_TEAM_BUCKET_POLICIES_ARN,
        "LAMBDA_DELETE_TEAM_BUCKET_POLICIES_ARN": TEST_LAMBDA_DELETE_TEAM_BUCKET_POLICIES_ARN,
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
        "team": {
            "slug": TEST_TEAM_SLUG,
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
