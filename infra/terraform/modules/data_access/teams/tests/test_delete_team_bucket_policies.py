import json
from mock import call

import pytest

import teams

from tests.conftest import (
    TEST_GROUP_NAME,
    TEST_READONLY_POLICY_ARN,
    TEST_READWRITE_POLICY_ARN,
    TEST_ROLE_NAME,
    TEST_TEAM_SLUG,
    TEST_USER_NAME
)


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_when_the_team_is_deleted_the_bucket_policies_are_detached_from_everything(iam_client_mock):
    teams.delete_team_bucket_policies({"team": {"slug": TEST_TEAM_SLUG}}, None)

    # Policies detached from from roles
    calls = [
        call(
            RoleName=TEST_ROLE_NAME,
            PolicyArn=TEST_READONLY_POLICY_ARN,
        ),
        call(
            RoleName=TEST_ROLE_NAME,
            PolicyArn=TEST_READWRITE_POLICY_ARN,
        ),
    ]
    iam_client_mock.detach_role_policy.assert_has_calls(calls)

    # Policies detached from groups
    calls = [
        call(
            GroupName=TEST_GROUP_NAME,
            PolicyArn=TEST_READONLY_POLICY_ARN,
        ),
        call(
            GroupName=TEST_GROUP_NAME,
            PolicyArn=TEST_READWRITE_POLICY_ARN,
        ),
    ]
    iam_client_mock.detach_group_policy.assert_has_calls(calls)

    # Policies detached from users
    calls = [
        call(
            UserName=TEST_USER_NAME,
            PolicyArn=TEST_READONLY_POLICY_ARN,
        ),
        call(
            UserName=TEST_USER_NAME,
            PolicyArn=TEST_READWRITE_POLICY_ARN,
        ),
    ]
    iam_client_mock.detach_user_policy.assert_has_calls(calls)


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_when_the_team_is_deleted_the_bucket_policies_are_deleted(iam_client_mock):
    teams.delete_team_bucket_policies({"team": {"slug": TEST_TEAM_SLUG}}, None)

    calls = [
        call(PolicyArn=TEST_READONLY_POLICY_ARN),
        call(PolicyArn=TEST_READWRITE_POLICY_ARN),
    ]

    iam_client_mock.delete_policy.assert_has_calls(calls)
