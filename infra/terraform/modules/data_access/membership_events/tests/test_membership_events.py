import boto3
from botocore.exceptions import ClientError
import pytest

import membership_events


from tests.conftest import (
    sns_event,
    TEST_ATTACH_BUCKET_POLICY_ARN,
    TEST_DETACH_BUCKET_POLICY_ARN,
    TEST_PAYLOAD_BYTES
)


@pytest.mark.parametrize("event,lambda_arn", [
    (sns_event("added"), TEST_ATTACH_BUCKET_POLICY_ARN),
    (sns_event("removed"), TEST_DETACH_BUCKET_POLICY_ARN)
])
@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_lambda_is_available",
)
def test_when_event_received_is_handled(lambda_client_mock, event, lambda_arn):
    membership_events.event_received(event, None)

    # Test right lambda function is invoked asyncronously
    lambda_client_mock.invoke.assert_called_with(
        FunctionName=lambda_arn,
        Payload=TEST_PAYLOAD_BYTES,
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
