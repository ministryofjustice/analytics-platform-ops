import json

import pytest

import teams

from tests.conftest import TEST_TEAM_SLUG, TEST_BUCKET_NAME, TEST_BUCKET_REGION


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_s3_is_available",
)
def test_when_the_team_is_created_the_bucket_is_created(s3_client_mock):
    teams.create_team_bucket({"team": {"slug": TEST_TEAM_SLUG}}, None)

    s3_client_mock.create_bucket.assert_called_with(
        Bucket=TEST_BUCKET_NAME,
        ACL="private",
        CreateBucketConfiguration={
            "LocationConstraint": TEST_BUCKET_REGION,
        },
    )
