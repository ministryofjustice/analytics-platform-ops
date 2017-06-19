import json

import pytest

import users

from tests.conftest import TEST_ROLE_NAME, TEST_USERNAME


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_create_user_role_success(iam_client_mock, trust_relationship):
    users.create_user_role({"username": TEST_USERNAME}, None)

    # Test role is created
    iam_client_mock.create_role.assert_called_with(
        RoleName=TEST_ROLE_NAME,
        AssumeRolePolicyDocument=json.dumps(trust_relationship),
    )
