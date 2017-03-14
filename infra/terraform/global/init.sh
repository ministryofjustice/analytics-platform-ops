#!/bin/bash
set -ex

if [ $# -lt 2 ]; then
  echo 1>&2 "$0: Arguments: BUCKET_NAME REGION"
  exit 2
fi

BUCKET_NAME=${1}
REGION=${2}

terraform remote config \
    -backend=s3 \
    -backend-config="bucket=${BUCKET_NAME}" \
    -backend-config="key=base/terraform.tfstate" \
    -backend-config="region=${REGION}"
