#!/bin/bash
set -ex

PLATFORM_ENV=$1
USERNAME=$(echo $2 | tr '[:upper:]' '[:lower:]')
AWS_IAM_ROLE="${PLATFORM_ENV}_user_${USERNAME}"
DOCKER_TAG=$3


# initialize Helm client
helm init -c

RELEASE_NAME=${USERNAME}-rstudio

# Install/upgrade RStudio helm chart
helm upgrade ${RELEASE_NAME} charts/rstudio \
    -f chart-env-config/${PLATFORM_ENV}/rstudio.yml \
    --set Username=${USERNAME} \
    --set AWS.IAMRole=${AWS_IAM_ROLE} \
    --set RStudio.Image.Tag=${DOCKER_TAG} \
    --namespace user-${USERNAME} \
    --install --wait
