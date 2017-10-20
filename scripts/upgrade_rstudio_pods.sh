#!/usr/bin/env bash
set -ex

RSTUDIO_DOCKER_TAG=${1:-"latest"}
PROXY_DOCKER_TAG=${2:-"latest"}

env=$(kubectl config current-context | cut -f 1 -d .)

helm repo update

for user in $(kubectl get ns | grep user- | cut -f 1 -d ' ' | sed 's/^user-//'); do
    namespace=user-$user

    helm upgrade $user-rstudio mojanalytics/rstudio \
        -f ../analytics-platform-config/chart-env-config/$env/rstudio.yml \
        --set username=$user \
        --set aws.iamRole=${env}_user_${user} \
        --set rstudio.image.tag=$RSTUDIO_DOCKER_TAG \
        --set authProxy.image.tag=$PROXY_DOCKER_TAG \
        --namespace $namespace \
        --install
done
