import json
from mock import call

import pytest

import teams

from tests.conftest import TEST_TEAM_SLUG, TEST_READONLY_POLICY_DOCUMENT, \
    TEST_READWRITE_POLICY_DOCUMENT, TEST_BUCKET_NAME


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_when_the_team_is_created_the_bucket_policies_are_created(iam_client_mock):
    teams.create_team_bucket_policies({"team": {"slug": TEST_TEAM_SLUG}}, None)

    calls = [
        call(
            PolicyName="{}-readonly".format(TEST_BUCKET_NAME),
            Path="/teams/",
            PolicyDocument=json.dumps(TEST_READONLY_POLICY_DOCUMENT),
        ),
        call(
            PolicyName="{}-readwrite".format(TEST_BUCKET_NAME),
            Path="/teams/",
            PolicyDocument=json.dumps(TEST_READWRITE_POLICY_DOCUMENT),
        )
    ]

    iam_client_mock.create_policy.assert_has_calls(calls)
