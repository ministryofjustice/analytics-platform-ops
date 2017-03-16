#!/bin/bash
set -ex

PLATFORM_ENV=$1
USERNAME=$(echo $2 | tr '[:upper:]' '[:lower:]')

# initialize Helm client
helm init -c

RELEASE_NAME=config-user-${USERNAME}

# Install/upgrade the init-user helm chart
helm upgrade ${RELEASE_NAME} charts/config-user \
    --namespace user-${USERNAME} \
    --set Username="$USERNAME" \
    --install --wait
