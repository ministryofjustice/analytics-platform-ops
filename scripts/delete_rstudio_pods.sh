#!/usr/bin/env bash

for ns in $(kubectl get ns | grep user- | cut -f 1 -d ' '); do
    kubectl delete pods -l app=rstudio -n $ns
done
