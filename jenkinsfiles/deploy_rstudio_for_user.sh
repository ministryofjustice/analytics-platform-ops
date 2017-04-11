#!/bin/bash
set -ex

PLATFORM_ENV=$1
USERNAME=$(echo $2 | tr '[:upper:]' '[:lower:]')
AWS_ACCESS_KEY_ID=$3
AWS_SECRET_ACCESS_KEY=$4

# initialize Helm client
helm init -c

RELEASE_NAME=${USERNAME}-rstudio

# Install/upgrade RStudio helm chart
helm upgrade ${RELEASE_NAME} charts/rstudio \
    -f chart-env-config/${PLATFORM_ENV}/rstudio.yml \
    --set Username=${USERNAME} \
    --set AWS.AccessKeyId=${AWS_ACCESS_KEY_ID} \
    --set AWS.SecretAccessKey=${AWS_SECRET_ACCESS_KEY} \
    --namespace user-${USERNAME} \
    --install --wait
