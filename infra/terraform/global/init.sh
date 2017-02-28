#!/bin/bash
set -ex

REGION=eu-west-1
BUCKET_NAME=terraform.analytics.justice.gov.uk
KEY=base/terraform.tfstate

terraform remote config \
    -backend=s3 \
    -backend-config="bucket=${BUCKET_NAME}" \
    -backend-config="key=${KEY}" \
    -backend-config="region=${REGION}"
