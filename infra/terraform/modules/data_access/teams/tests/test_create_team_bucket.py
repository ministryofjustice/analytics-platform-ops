import pytest

import teams

from tests.conftest import (TEST_TEAM_SLUG, TEST_BUCKET_NAME,
                            TEST_BUCKET_REGION, TEST_LOGS_BUCKET_NAME,
                            TEST_LOGS_PREFIX)


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


@pytest.mark.usefixtures(
    "given_the_env_is_set",
    "given_s3_is_available",
)
def test_when_team_bucket_is_created_logging_is_enabled(s3_client_mock):
    teams.create_team_bucket({"team": {"slug": TEST_TEAM_SLUG}}, None)

    s3_client_mock.put_bucket_logging.assert_called_with(
        Bucket=TEST_BUCKET_NAME,
        BucketLoggingStatus={
            'LoggingEnabled': {
                'TargetBucket': TEST_LOGS_BUCKET_NAME,
                'TargetPrefix': TEST_LOGS_PREFIX
            }
        },
    )
