#!/bin/bash
set -ex

PLATFORM_ENV=$1
APP_NAME=$(echo $2 | tr '[:upper:]' '[:lower:]')
REPO_URL=$3
BRANCH=$4
REVISION=$5

RELEASE_NAME=shiny-app-${APP_NAME}

# initialize Helm client
helm init -c

# Install/upgrade the shiny-app helm chart
helm upgrade ${RELEASE_NAME} charts/shiny-app \
    -f chart-env-config/${PLATFORM_ENV}/shiny-app.yml \
    --set app.name="$APP_NAME" \
    --set gitSync.repository="$REPO_URL" \
    --set gitSync.branch="$BRANCH" \
    --set gitSync.revision="$REVISION" \
    --install --wait
