import json

import pytest

import users


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_create_user_role_success(iam_client_mock, username, role_name, trust_relationship):
    users.create_user_role({"username": username}, None)

    # Test role is created
    iam_client_mock.create_role.assert_called_with(
        RoleName=role_name,
        Path="/users/",
        AssumeRolePolicyDocument=json.dumps(trust_relationship),
    )
