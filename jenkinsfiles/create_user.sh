#!/bin/bash
set -ex

# Example:
#  $ ./create_user.sh dev username first.last@example.com 'First Last Jr.'

PLATFORM_ENV=$1
USERNAME=$(echo $2 | tr '[:upper:]' '[:lower:]')
EMAIL=$(echo $3 | tr '[:upper:]' '[:lower:]')
FULLNAME=$4

# initialize Helm client
helm init -c

RELEASE_NAME=init-user-${USERNAME}

FULLNAME_PARAM=""

# Install/upgrade the init-user helm chart
helm upgrade ${RELEASE_NAME} charts/init-user \
    -f chart-env-config/${PLATFORM_ENV}/init-user.yml \
    --set Username=${USERNAME} \
    --set Email=${EMAIL} \
    --set Fullname="$FULLNAME" \
    --install --wait
