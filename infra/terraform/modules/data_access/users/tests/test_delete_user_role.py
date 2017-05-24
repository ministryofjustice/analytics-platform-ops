import pytest

import users


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_delete_user_role_success(iam_client_mock, username, role_name, role_policy_arn):
    users.delete_user_role({"username": username}, None)

    # Test detaches policies
    iam_client_mock.detach_role_policy.assert_called_with(
        RoleName=role_name,
        PolicyArn=role_policy_arn,
    )

    # Test role is deleted
    iam_client_mock.delete_role.assert_called_with(
        RoleName=role_name
    )
