#!/usr/bin/env bash

for ns in $(kubectl get ns | grep user- | cut -f 1 -d ' '); do
    echo \
        $(kubectl get secret user-secrets -n $ns -o jsonpath="{.data.fullname}" | base64 --decode) ", " \
        $(kubectl get secret user-secrets -n $ns -o jsonpath="{.data.username}" | base64 --decode) ", " \
        $(kubectl get secret user-secrets -n $ns -o jsonpath="{.data.email}" | base64 --decode)
done
