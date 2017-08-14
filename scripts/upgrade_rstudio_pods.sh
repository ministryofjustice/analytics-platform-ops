#!/usr/bin/env bash
set -ex

DOCKER_TAG=${1:-"latest"}

env=$(kubectl config current-context | cut -f 1 -d .)

helm repo update

for user in $(kubectl get ns | grep user- | cut -f 1 -d ' ' | sed 's/^user-//'); do
    namespace=user-$user

    helm upgrade $user-rstudio mojanalytics/rstudio \
        -f ../analytics-platform-config/chart-env-config/$env/rstudio.yml \
        --set Username=$user \
        --set AWS.IAMRole=${env}_user_${user} \
        --set RStudio.Image.Tag=$DOCKER_TAG \
        --namespace $namespace \
        --install
done
