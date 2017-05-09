from hashlib import sha1
from moto import mock_sns
import boto3
import hmac
import json
import os

import pytest


#################
#  Tests state  #
#################


@pytest.fixture
def state():
    return {
        "event": {
            "headers": {
                "X-Hub-Signature": "signature",
                "X-GitHub-Event": "team",
            },
            "body": "{\"a JSON string\": true}",
        }
    }


###########
#  Event  #
###########


@pytest.fixture
def event(state):
    return state["event"]


@pytest.fixture
def event_type(event):
    return event["headers"]["X-GitHub-Event"]


###############
#  Signature  #
###############


@pytest.fixture
def given_invalid_signature(state):
    state["event"]["headers"]["X-Hub-Signature"] = "sha3=invalid"


@pytest.fixture
def given_valid_signature(state, secret):
    message = "hello this is dog"
    signature = sha1_signature(message, secret)

    state["event"]["body"] = message
    state["event"]["headers"]["X-Hub-Signature"] = signature


def sha1_signature(message, secret):
    mac = hmac.new(
        secret.encode("utf-8"),
        msg=message.encode("utf-8"),
        digestmod=sha1
    )
    return "sha1={}".format(mac.hexdigest())


############
#  Config  #
############


@pytest.fixture
def given_the_env_is_set(sns_arn, secret):
    os.environ["SNS_ARN"] = sns_arn
    os.environ["STAGE"] = "test"
    os.environ["GH_HOOK_SECRET"] = secret


@pytest.fixture
def sns_arn():
    return "arn:aws:sns:eu-west-1:123456789012"


@pytest.fixture
def secret():
    return "The secret shared with GitHub"


###############
#  SNS Topic  #
###############


@pytest.fixture
def topic(event_type):
    return "{stage}_github_{event_type}_events".format(
        stage=os.environ["STAGE"],
        event_type=event_type,
    )


@pytest.fixture
def topic_arn(sns_arn, topic):
    return "{sns_arn}:{topic}".format(
        sns_arn=sns_arn,
        topic=topic
    )


######################
#  SNS setup / Moto  #
######################


@pytest.yield_fixture
def given_sns_is_available():
    with mock_sns():
        yield


@pytest.fixture
def given_the_topic_exists(topic):
    sns = boto3.client("sns")
    # NOTE: create_topic() gets the topic name *not* the full topic ARN
    sns.create_topic(Name=topic)


@pytest.fixture
def given_the_topic_doesnt_exist(topic_arn):
    sns = boto3.client("sns")
    topics = sns.list_topics()["Topics"]

    for t in topics:
        if t["TopicArn"] == topic_arn:
            sns.delete_topic(TopicArn=topic)
