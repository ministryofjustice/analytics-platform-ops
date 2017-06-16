import json
import mock

import boto3
import pytest


TEST_SAML_PROVIDER_ARN = "arn:aws:iam::123456789012:saml-provider/auth0"
TEST_K8S_WORKER_ROLE_ARN = "arn:aws:iam::123456789012:role/nodes.test.example.com"
TEST_STAGE = "test"
TEST_USERNAME = "alice"
TEST_ROLE_NAME = "{}_{}".format(TEST_STAGE, TEST_USERNAME)

TEST_ROLE_POLICY_ARN = "test_policy_arn"


@pytest.yield_fixture
def given_the_env_is_set():
    with mock.patch.dict("os.environ", {
        "STAGE": TEST_STAGE,
        "SAML_PROVIDER_ARN": TEST_SAML_PROVIDER_ARN,
        "K8S_WORKER_ROLE_ARN": TEST_K8S_WORKER_ROLE_ARN,
    }):
        yield


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
            },
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            },
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": TEST_K8S_WORKER_ROLE_ARN
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }


@pytest.fixture
def iam_client_mock():
    client = mock.create_autospec(boto3.client("iam"))

    attached_policies = {
        "AttachedPolicies": [
            {
                "PolicyArn": TEST_ROLE_POLICY_ARN,
            }
        ]
    }
    client.list_attached_role_policies = mock.Mock(
        return_value=attached_policies
    )

    return client


@pytest.yield_fixture
def given_iam_is_available(iam_client_mock):
    with mock.patch.object(boto3, "client", return_value=iam_client_mock):
        yield
