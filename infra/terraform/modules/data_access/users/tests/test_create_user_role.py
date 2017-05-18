import boto3
from botocore.exceptions import ClientError
import pytest

import users


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_iam_is_available",
)
def test_create_user_role_success(username, role_name):
    users.create_user_role({"username": username}, None)

    try:
        client = boto3.client("iam")
        role = client.get_role(RoleName=role_name)
    except Exception:
        pytest.fail("Failed to read the role. Was it created?")
