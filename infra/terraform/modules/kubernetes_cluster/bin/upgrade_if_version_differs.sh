#!/usr/bin/env bash

set -eu -o pipefail

DOMAIN=$1
DECLARED_VERSION=$2

# make sure we're looking at the right cluster
kubectl config use-context $DOMAIN

CURRENT_VERSION=$(kubectl version --short | sed -En 's/^Server.+v(.+)$/\1/p')

if [[ $CURRENT_VERSION != $DECLARED_VERSION ]]
then
    kops get cluster $DOMAIN -oyaml | \
        sed -E "s/kubernetesVersion: [.0-9]+/kubernetesVersion: $DECLARED_VERSION/g" \
        > cluster.yml

    kops replace -f cluster.yml
    rm cluster.yml

    kops update cluster $DOMAIN --yes
    kops rolling-update cluster $DOMAIN --yes
fi
