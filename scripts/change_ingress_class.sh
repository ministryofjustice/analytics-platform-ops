#!/usr/bin/env bash

INGRESS_CLASS=${1:-"istio"}

for ns in $(kubectl get ns --no-headers | cut -f 1 -d ' '); do
    for ing in $(kubectl get ing --no-headers -n $ns --ignore-not-found=true| cut -f 1 -d ' '); do
        export annotations=$(kubectl get ing $ing -n $ns -o=jsonpath='{.metadata.annotations}')
        echo " Updating: $ns/$ing $annotations"
        #kubectl patch ing $ing -n $ns -p '{"metadata": {"annotations": {"kubernetes.io/ingress.class":"$INGRESS_CLASS"} } }'

        # do we need this?
        #kubectl patch ing $ing -n $ns -p '[{"op": "remove", "path": "/spec/tls"}]' --type=json

        # TODO path
    done
done