import json
import mock

import boto3
import pytest


TEST_SAML_PROVIDER_ARN = "arn:aws:iam::123456789012:saml-provider/auth0"
TEST_STAGE = "test"
TEST_USERNAME = "alice"

TEST_ROLE_POLICY_ARN = "test_policy_arn"


@pytest.fixture
def username():
    return TEST_USERNAME


@pytest.yield_fixture
def given_the_env_is_set():
    with mock.patch.dict("os.environ", {
        "STAGE": TEST_STAGE,
        "SAML_PROVIDER_ARN": TEST_SAML_PROVIDER_ARN,
    }):
        yield


@pytest.fixture
def role_name():
    return "{env}_{username}_role".format(
        env=TEST_STAGE,
        username=TEST_USERNAME,
    )


@pytest.fixture
def trust_relationship():
    return {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": TEST_SAML_PROVIDER_ARN,
                },
                "Action": "sts:AssumeRoleWithSAML",
                "Condition": {
                    "StringEquals": {
                        "SAML:aud": "https://signin.aws.amazon.com/saml"
                    }
                }
            }
        ]
    }


@pytest.fixture
def role_policy_arn():
    return TEST_ROLE_POLICY_ARN


@pytest.fixture
def role_policies(role_policy_arn):
    return {
        "AttachedPolicies": [
            {
                "PolicyArn": role_policy_arn,
            }
        ]
    }


@pytest.fixture
def iam_client_mock(role_policies):
    client = mock.create_autospec(boto3.client("iam"))

    client.list_attached_role_policies = mock.Mock(
        return_value=role_policies
    )

    return client


@pytest.yield_fixture
def given_iam_is_available(iam_client_mock):
    with mock.patch.object(boto3, "client", return_value=iam_client_mock):
        yield
