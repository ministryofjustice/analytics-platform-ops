#!/usr/bin/env bash

for ns in $(kubectl get ns --no-headers | cut -f 1 -d ' '); do
    echo "working on ns: $ns"
    for ing in $(kubectl get ing --no-headers -n $ns --ignore-not-found=true| cut -f 1 -d ' '); do
        export annotations=$(kubectl get ing $ing -n $ns -o=jsonpath='{.metadata.annotations}')
        if [[ $annotations = *"nginx"* ]]; then
            echo " 👌 Updating: $ns/$ing $annotations"
            kubectl patch ing $ing -n $ns -p '{"metadata": {"annotations": {"kubernetes.io/ingress.class":"istio"} } }'
            # do we need this? NO?
            #kubectl patch ing $ing -n $ns -p '[{"op": "remove", "path": "/spec/tls"}]' --type=json
            
            # just delete's path from the first path in the ingress but that's ok
            # because we only set one path
            kubectl patch ing $ing -n $ns -p '[{"op": "remove", "path": "/spec/rules/0/http/paths/0/path"}]' --type=json
        else
            echo " ⛔ Skipping: $ns/$ing $annotations"
        fi
    done
done