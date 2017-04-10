#!/bin/bash
set -ex

PLATFORM_ENV=$1
USERNAME=$(echo $2 | tr '[:upper:]' '[:lower:]')

# initialize Helm client
helm init -c

RELEASE_NAME=${USERNAME}-rstudio

# Install/upgrade RStudio helm chart
helm upgrade ${RELEASE_NAME} charts/rstudio \
    -f chart-env-config/${PLATFORM_ENV}/rstudio.yml \
    --set Username=${USERNAME} \
    --namespace user-${USERNAME} \
    --install --wait
