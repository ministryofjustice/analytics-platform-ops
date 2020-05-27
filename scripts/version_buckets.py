"""
Reads all the current buckets, ensures that versioning is switched on for those
that don't yet have it and sets the life cycle configuration to send
non-current versions of files to glacier storage after 30 days.

This script should only be run once, when the following PR lands in master in
the control panel:

https://github.com/ministryofjustice/analytics-platform-control-panel/pull/816

(From that moment on, all S3 buckets will be configured in this way by the
control panel, as a default.)
"""
import boto3


s3 = boto3.client('s3')
buckets = s3.list_buckets()
for bucket_dict in buckets["Buckets"]:
    bucket_name = bucket_dict["Name"]
    if not bucket_name.startswith("alpha"):
        # Only deal with buckets created and used by/for the control panel
        # (always prefixed with "alpha").
        continue
    print(f"Working on {bucket_name}.")
    bucket = boto3.resource("s3").Bucket(bucket_name)
    # Add versioning if not already set.
    versioning = bucket.Versioning()
    if not versioning.status == "Enabled":
        print(f"Enabling versioning for {bucket_name}.")
        versioning.enable()
    # Set life cycle rule to send non-current versions of files to glacier
    # storage after 30 days.
    lifecycle_id = f"{bucket_name}_lifecycle_configuration"
    print(f"Setting lifecycle {lifecycle_id} for bucket {bucket_name}.")
    lifecycle_conf = boto3.client("s3").put_bucket_lifecycle_configuration(
        Bucket=bucket_name,
        LifecycleConfiguration={
            "Rules": [
                {
                    "ID": lifecycle_id,
                    "Status": "Enabled",
                    "Prefix": "",
                    "NoncurrentVersionTransitions": [
                        {
                            'NoncurrentDays': 30,
                            'StorageClass': 'GLACIER',
                        },
                    ]
                },
            ]
        }
    )
