#!/bin/bash
set -ex

# Example:
#  $ ./create_user.sh dev username first.last@example.com 'First Last Jr.'

PLATFORM_ENV=$1
USERNAME=$(echo $2 | tr '[:upper:]' '[:lower:]')
EMAIL=$3
FULLNAME=$4

# initialize Helm client
helm init -c

# Install/upgrade the init-user helm chart
helm upgrade init-user-${USERNAME} charts/init-user \
    -f chart-env-config/${PLATFORM_ENV}/init-user.yml \
    --set Username="$USERNAME" \
    --set Email="$EMAIL" \
    --set Fullname="$FULLNAME" \
    --install --wait

# Install/upgrade the config-user helm chart
helm upgrade config-user-${USERNAME} charts/config-user \
    --namespace user-${USERNAME} \
    --set Username="$USERNAME" \
    --install --wait
