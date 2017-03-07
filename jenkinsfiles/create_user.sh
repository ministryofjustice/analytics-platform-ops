#!/bin/bash
set -e

USERNAME=$(echo $1 | tr '[:upper:]' '[:lower:]')
PLATFORM_ENV=$2

# initialize Helm client
helm init -c

RELEASE_NAME=init-user-${USERNAME}

# Install if release isn't currently listed, otherwise upgrade
if [[ -z "$(helm list ${RELEASE_NAME})" ]]; then
    helm install charts/init-user \
        -f chart-env-config/${PLATFORM_ENV}/init-user.yml \
        --name ${RELEASE_NAME} \
        --set Username=${USERNAME}
else
    helm upgrade ${RELEASE_NAME} charts/init-user \
        -f chart-env-config/${PLATFORM_ENV}/init-user.yml \
        --set Username=${USERNAME}
fi
