import boto3
from botocore.exceptions import ClientError
import pytest

import organization_events


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_lambda_is_available",
)
def test_event_received_member_added(lambda_client_mock, member_added_event, create_role_arn, payload_bytes):
    organization_events.event_received(member_added_event, None)

    # Test right lambda function is invoked asyncronously
    lambda_client_mock.invoke.assert_called_with(
        FunctionName=create_role_arn,
        Payload=payload_bytes,
        InvocationType="Event",
    )


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_lambda_is_available",
)
def test_event_received_member_removed(lambda_client_mock, member_removed_event, delete_role_arn, payload_bytes):
    organization_events.event_received(member_removed_event, None)

    # Test right lambda function is invoked asyncronously
    lambda_client_mock.invoke.assert_called_with(
        FunctionName=delete_role_arn,
        Payload=payload_bytes,
        InvocationType="Event",
    )
