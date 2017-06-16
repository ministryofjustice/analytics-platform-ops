import boto3
import pytest

import membership_events


from tests.conftest import (
    sns_event,
    TEST_ATTACH_BUCKET_POLICY_ARN,
    TEST_DETACH_BUCKET_POLICIES_ARN,
    TEST_ATTACH_PAYLOAD_BYTES,
    TEST_DETACH_PAYLOAD_BYTES,
)


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_lambda_is_available",
)
def test_when_event_added_invokes_attach_lambda(lambda_client_mock):
    event = sns_event("added")
    membership_events.event_received(event, None)

    # Test right lambda function is invoked asyncronously
    lambda_client_mock.invoke.assert_called_with(
        FunctionName=TEST_ATTACH_BUCKET_POLICY_ARN,
        Payload=TEST_ATTACH_PAYLOAD_BYTES,
        InvocationType="Event",
    )


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_lambda_is_available",
)
def test_when_event_removed_invokes_detach_lambda(lambda_client_mock):
    event = sns_event("removed")
    membership_events.event_received(event, None)

    # Test right lambda function is invoked asyncronously
    lambda_client_mock.invoke.assert_called_with(
        FunctionName=TEST_DETACH_BUCKET_POLICIES_ARN,
        Payload=TEST_DETACH_PAYLOAD_BYTES,
        InvocationType="Event",
    )


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_lambda_is_available",
)
def test_when_event_scope_not_team_event_is_ignored(lambda_client_mock):
    event = sns_event("some_action")
    event["scope"] = "other_scope"

    membership_events.event_received(event, None)

    # No lambda function is invoked
    lambda_client_mock.invoke.assert_not_called()
