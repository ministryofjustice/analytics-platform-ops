#!/bin/bash
set -ex

PLATFORM_ENV=$1
USERNAME=$(echo $2 | tr '[:upper:]' '[:lower:]')

# initialize Helm client
helm init -c

RELEASE_NAME=rstudio-${USERNAME}

# Install if release isn't currently listed, otherwise upgrade
if [[ -z "$(helm list ${RELEASE_NAME})" ]]; then
    helm install charts/rstudio \
        -f chart-env-config/${PLATFORM_ENV}/rstudio.yml \
        --name ${RELEASE_NAME} \
        --set Username=${USERNAME} \
        --namespace user-${USERNAME}
else
    helm upgrade ${RELEASE_NAME} charts/rstudio \
        -f chart-env-config/${PLATFORM_ENV}/rstudio.yml \
        --set Username=${USERNAME}
fi
