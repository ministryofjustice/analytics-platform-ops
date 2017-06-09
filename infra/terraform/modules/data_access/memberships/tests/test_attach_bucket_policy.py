import json

import pytest

import memberships

from tests.conftest import (
    TEST_READ_ONLY_POLICY_ARN,
    TEST_READ_WRITE_POLICY_ARN,
    TEST_ROLE_NAME,
    TEST_TEAM_SLUG,
    TEST_USERNAME,
)


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_when_policy_type_is_invalid_raise_exception():
    event = {
        "policy": {"type": "Invalid!"},
    }
    with pytest.raises(memberships.InvalidPolicyType):
        memberships.attach_bucket_policy(event, None)


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_when_policy_type_reaonly_attaches_it_to_right_role(iam_client_mock):
    event = {
        "policy": {"type": memberships.POLICY_READ_ONLY},
        "user": {"username": TEST_USERNAME},
        "team": {"slug": TEST_TEAM_SLUG},
    }
    memberships.attach_bucket_policy(event, None)

    iam_client_mock.attach_role_policy.assert_called_with(
        PolicyArn=TEST_READ_ONLY_POLICY_ARN,
        RoleName=TEST_ROLE_NAME,
    )


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_when_policy_type_reawrite_attaches_it_to_right_role(iam_client_mock):
    event = {
        "policy": {"type": memberships.POLICY_READ_WRITE},
        "user": {"username": TEST_USERNAME},
        "team": {"slug": TEST_TEAM_SLUG},
    }
    memberships.attach_bucket_policy(event, None)

    iam_client_mock.attach_role_policy.assert_called_with(
        PolicyArn=TEST_READ_WRITE_POLICY_ARN,
        RoleName=TEST_ROLE_NAME,
    )
