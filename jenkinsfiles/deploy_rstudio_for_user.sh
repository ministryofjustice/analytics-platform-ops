#!/bin/bash
set -ex

PLATFORM_ENV=$1
USERNAME=$(echo $2 | tr '[:upper:]' '[:lower:]')
DOCKER_TAG=$3
AWS_ACCESS_KEY_ID=$4
AWS_SECRET_ACCESS_KEY=$5

# initialize Helm client
helm init -c

RELEASE_NAME=${USERNAME}-rstudio

# Install/upgrade RStudio helm chart
helm upgrade ${RELEASE_NAME} charts/rstudio \
    -f chart-env-config/${PLATFORM_ENV}/rstudio.yml \
    --set Username=${USERNAME} \
    --set AWS.AccessKeyId=${AWS_ACCESS_KEY_ID} \
    --set AWS.SecretAccessKey=${AWS_SECRET_ACCESS_KEY} \
    --set RStudio.Image.Tag=${DOCKER_TAG} \
    --namespace user-${USERNAME} \
    --install --wait
