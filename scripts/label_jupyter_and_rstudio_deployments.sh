#!/usr/bin/env bash
set -ex

IDLEABLE_LABEL=${1:-"mojanalytics.xyz/idleable"}

for user in $(kubectl get ns | grep user- | cut -f 1 -d ' ' | sed 's/^user-//'); do
    namespace=user-$user

    kubectl label deployments -l app=rstudio ${IDLEABLE_LABEL}=true -n $namespace
    kubectl label deployments -l app=jupyter-lab ${IDLEABLE_LABEL}=true -n $namespace

done
