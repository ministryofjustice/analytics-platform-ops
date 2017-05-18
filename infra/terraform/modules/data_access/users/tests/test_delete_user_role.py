import boto3
from botocore.exceptions import ClientError
import pytest

import users


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
    "given_the_role_exists",
)
def test_delete_user_role_success(username, role_name):
    users.delete_user_role({"username": username}, None)

    with pytest.raises(Exception):
        client = boto3.client("iam")
        role = client.get_role(RoleName=role_name)
