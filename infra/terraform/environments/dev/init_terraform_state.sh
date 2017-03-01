#!/bin/bash
set -ex

if [ $# -lt 3 ]; then
  echo 1>&2 "$0: Arguments: BUCKET_NAME ENV_NAME REGION"
  exit 2
fi

BUCKET_NAME=${1}
ENV_NAME=${2}
REGION=${3}

cd $TF_ENV_DIR

terraform remote config \
    -backend=s3 \
    -backend-config="bucket=${BUCKET_NAME}" \
    -backend-config="key=${ENV_NAME}/terraform.tfstate" \
    -backend-config="region=${REGION}"
