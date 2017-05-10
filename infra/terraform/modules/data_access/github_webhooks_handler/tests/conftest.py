from hashlib import sha1
import hmac
import json
from unittest.mock import patch

import boto3
from moto import mock_sns
import pytest


TEST_SECRET = "The secret shared with GitHub"
TEST_MESSAGE = "hello this is dog"
TEST_SIGNATURE = "sha1=877781130156a6ee684aab8bb16fa5158e7d160b"
TEST_SNS_ARN = "arn:aws:sns:eu-west-1:123456789012"
TEST_TOPIC = "test_github_team_events"
TEST_TOPIC_ARN = "{}:{}".format(TEST_SNS_ARN, TEST_TOPIC)


@pytest.fixture
def state():
    return {
        "event": {
            "headers": {
                "X-Hub-Signature": "signature",
                "X-GitHub-Event": "team",
            },
            "body": '{"json event payload": true}',
        }
    }


@pytest.fixture
def event(state):
    return state["event"]


@pytest.fixture
def given_invalid_signature(state):
    state["event"]["headers"]["X-Hub-Signature"] = "sha3=invalid"


@pytest.fixture
def given_valid_signature(state):
    state["event"]["body"] = TEST_MESSAGE
    state["event"]["headers"]["X-Hub-Signature"] = TEST_SIGNATURE


@pytest.yield_fixture
def given_the_env_is_set():
    with patch.dict('os.environ', {
        "SNS_ARN": TEST_SNS_ARN,
        "STAGE": "test",
        "GH_HOOK_SECRET": TEST_SECRET,
    }):
        yield


@pytest.fixture
def topic_arn():
    return TEST_TOPIC_ARN


@pytest.yield_fixture
def given_sns_is_available():
    with mock_sns():
        yield


@pytest.fixture
def given_the_topic_exists():
    sns = boto3.client("sns")
    # NOTE: create_topic() gets the topic name *not* the full topic ARN
    sns.create_topic(Name=TEST_TOPIC)
