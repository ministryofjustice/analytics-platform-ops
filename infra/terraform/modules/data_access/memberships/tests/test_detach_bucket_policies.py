import json
from mock import call

import botocore.exceptions
import pytest

import memberships

from tests.conftest import (
    TEST_READ_ONLY_POLICY_ARN,
    TEST_READ_WRITE_POLICY_ARN,
    TEST_ROLE_NAME,
    TEST_TEAM_SLUG,
    TEST_USERNAME,
)


def raise_detach_role_policy_exception(**kwarg):
    raise botocore.exceptions.ClientError(
        {
            "Error": {
                "Code": "NoSuchEntity",
                "Message": "Policy arn:... was not found.",
            }
        },
        "DetachRolePolicy"
    )


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_when_invoked_detaches_all_bucket_policies_from_the_role(iam_client_mock):
    '''
    This is to test the scenario when 1+ of the policies tried to be
    detached is not actually attached: In this case boto/AWS will still
    raise an exception but we still want to carry on and detach the rest of
    the policies.
    '''

    iam_client_mock.detach_role_policy.side_effect = raise_detach_role_policy_exception

    event = {
        "user": {"username": TEST_USERNAME},
        "team": {"slug": TEST_TEAM_SLUG},
    }
    memberships.detach_bucket_policies(event, None)

    calls = [
        call(
            PolicyArn=TEST_READ_WRITE_POLICY_ARN,
            RoleName=TEST_ROLE_NAME,
        ),
        call(
            PolicyArn=TEST_READ_ONLY_POLICY_ARN,
            RoleName=TEST_ROLE_NAME,
        ),
    ]

    iam_client_mock.detach_role_policy.assert_has_calls(calls)
