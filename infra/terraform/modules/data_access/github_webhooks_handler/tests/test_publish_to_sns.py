import json

import pytest

import github_webhooks


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_invalid_signature",
)
def test_cannot_publish_to_sns(event):
    response = github_webhooks.publish_to_sns(event, "context not used")
    response_body = json.loads(response["body"])

    assert response["statusCode"] == 401
    assert response_body["message"] == "Invalid signature"
    assert response["headers"]["Content-Type"] == "application/json"


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_valid_signature",
    "given_sns_is_available",
)
def test_nonexistent_topic(event, topic_arn):
    response = github_webhooks.publish_to_sns(event, "context not used")
    response_body = json.loads(response["body"])

    assert response["statusCode"] == 404
    assert response_body["message"] == "SNS topic '{}' not found".format(topic_arn)
    assert response["headers"]["Content-Type"] == "application/json"


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_valid_signature",
    "given_sns_is_available",
    "given_the_topic_exists",
)
def test_publish_success(event):
    response = github_webhooks.publish_to_sns(event, "context not used")
    response_body = json.loads(response["body"])

    assert response["statusCode"] == 201
    assert response_body["message"] == "Event published to SNS"
    assert response["headers"]["Content-Type"] == "application/json"
