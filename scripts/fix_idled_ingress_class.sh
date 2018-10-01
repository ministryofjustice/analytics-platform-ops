#!/usr/bin/env bash
set -e
###
# Find any deployments that are idled and set their ingress to 'disabled'
###

while read obj ns
do
    if [[ "$ns" == *"user-"* ]]; then
        echo $ns $obj
        read class <<< $(kubectl get ing -n $ns $obj -o=jsonpath='{.metadata.annotations.kubernetes\.io/ingress\.class}')
        if [[ "$class" == "nginx" ]]; then
            echo "patching ingress class from $class to 'disabled'"
            echo "  kubectl patch ing $obj -n $ns -p '{"metadata": {"annotations": {"kubernetes.io/ingress.class":"disabled"} } }'"
            kubectl patch ing $obj -n $ns -p '{"metadata": {"annotations": {"kubernetes.io/ingress.class":"disabled"} } }'
        else
            echo " ⛔ Skipping: $ns/$obj because they already have class $class"
        fi
    fi
done <<< $(kubectl get deployments --all-namespaces -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.namespace}{"\t"}{.metadata.labels.mojanalytics\.xyz/idled}{"\n"}{end}' | grep true | cut -f1,2)
