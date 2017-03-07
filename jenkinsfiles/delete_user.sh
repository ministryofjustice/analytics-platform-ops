#!/bin/bash
set -ex

USERNAME=$(echo $1 | tr '[:upper:]' '[:lower:]')

# initialize Helm client
helm init -c

RELEASE_NAME=init-user-${USERNAME}

helm delete ${RELEASE_NAME} --purge
