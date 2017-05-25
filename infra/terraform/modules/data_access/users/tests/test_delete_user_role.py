import pytest

import users

from tests.conftest import TEST_ROLE_NAME, TEST_USERNAME, TEST_ROLE_POLICY_ARN


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_delete_user_role_success(iam_client_mock):
    users.delete_user_role({"username": TEST_USERNAME}, None)

    # Test detaches policies
    iam_client_mock.detach_role_policy.assert_called_with(
        RoleName=TEST_ROLE_NAME,
        PolicyArn=TEST_ROLE_POLICY_ARN,
    )

    # Test role is deleted
    iam_client_mock.delete_role.assert_called_with(
        RoleName=TEST_ROLE_NAME
    )
