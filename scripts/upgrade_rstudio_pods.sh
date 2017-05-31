#!/usr/bin/env bash
set -ex

env=$(kubectl config current-context | cut -f 1 -d .)

for user in $(kubectl get ns | grep user- | cut -f 1 -d ' ' | cut -f 2 -d -); do
    namespace=user-$user
    secret_name=$(kubectl get secrets -n $namespace | grep rstudio | cut -f1 -d ' ')

    access_key=$(kubectl get secret $secret_name -n $namespace -o jsonpath="{.data.aws_access_key_id}" | base64 --decode)
    secret_key=$(kubectl get secret $secret_name -n $namespace -o jsonpath="{.data.aws_secret_access_key}" | base64 --decode)

    helm upgrade $user-rstudio charts/rstudio \
        -f chart-env-config/$env/rstudio.yml \
        --set Username=$user \
        --set AWS.AccessKeyId=$access_key \
        --set AWS.SecretAccessKey=$secret_key \
        --namespace $namespace \
        --install
done
