from mock import call

import boto3
from botocore.exceptions import ClientError
import pytest

import team_events


from tests.conftest import sns_event, TEST_PAYLOAD_BYTES, TEST_LAMBDA_CREATE_TEAM_BUCKET_ARN, \
    TEST_LAMBDA_CREATE_TEAM_BUCKET_POLICIES_ARN, \
    TEST_LAMBDA_DELETE_TEAM_BUCKET_POLICIES_ARN


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_lambda_is_available",
)
def test_when_team_created_bucket_and_policies_created(lambda_client_mock):
    team_events.event_received(sns_event("created"), None)

    calls = [
        call(
            FunctionName=TEST_LAMBDA_CREATE_TEAM_BUCKET_ARN,
            Payload=TEST_PAYLOAD_BYTES,
            InvocationType="Event",
        ),
        call(
            FunctionName=TEST_LAMBDA_CREATE_TEAM_BUCKET_POLICIES_ARN,
            Payload=TEST_PAYLOAD_BYTES,
            InvocationType="Event",
        )
    ]
    lambda_client_mock.invoke.assert_has_calls(calls)


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_lambda_is_available",
)
def test_when_team_deleted_bucket_policies_deleted(lambda_client_mock):
    team_events.event_received(sns_event("deleted"), None)

    lambda_client_mock.invoke.assert_called_with(
        FunctionName=TEST_LAMBDA_DELETE_TEAM_BUCKET_POLICIES_ARN,
        Payload=TEST_PAYLOAD_BYTES,
        InvocationType="Event",
    )
