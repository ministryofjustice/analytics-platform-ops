import json
from moto import mock_sns
import pytest

import github_webhooks


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_invalid_signature",
)
def test_cannot_publish_to_sns(event):
    '''
    when the signature is not valid
    it responds {401, "Invalid signature"}
    '''

    response = github_webhooks.publish_to_sns(event, "context not used")
    response_body = json.loads(response["body"])

    assert response["statusCode"] == 401
    assert response_body["message"] == "Invalid signature"
    assert response["headers"]["Content-Type"] == "application/json"


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_valid_signature",
    "given_sns_is_available",
    "given_the_topic_doesnt_exist",
)
def test_nonexistent_topic(event, topic_arn):
    '''
    when the signature is valid
    but the topic doesn't exist
    it responds {404, "SNS topic not found"}
    '''

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
    '''
    when the signature is valid
    and the topic exists
    it responds {201, "Event published to SNS"}
    '''

    response = github_webhooks.publish_to_sns(event, "context not used")
    response_body = json.loads(response["body"])

    assert response["statusCode"] == 201
    assert response_body["message"] == "Event published to SNS"
    assert response["headers"]["Content-Type"] == "application/json"
