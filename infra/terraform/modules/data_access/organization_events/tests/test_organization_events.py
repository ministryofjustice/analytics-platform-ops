import boto3
from botocore.exceptions import ClientError
import pytest

import organization_events


from tests.conftest import sns_event, TEST_PAYLOAD_BYTES, TEST_CREATE_ROLE_ARN, \
    TEST_DELETE_ROLE_ARN


@pytest.mark.parametrize("event,lambda_arn", [
    (sns_event("member_added"), TEST_CREATE_ROLE_ARN),
    (sns_event("member_removed"), TEST_DELETE_ROLE_ARN)
])
@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_lambda_is_available",
)
def test_when_event_received_is_handled(lambda_client_mock, event, lambda_arn):
    organization_events.event_received(event, None)

    # Test right lambda function is invoked asyncronously
    lambda_client_mock.invoke.assert_called_with(
        FunctionName=lambda_arn,
        Payload=TEST_PAYLOAD_BYTES,
        InvocationType="Event",
    )
