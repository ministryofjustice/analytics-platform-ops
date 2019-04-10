#!/usr/bin/env bash

# Remove the `mojanalytics.xyz/idled` label from unidled Deployments


set -e


kubectl get deployment --all-namespaces -l"mojanalytics.xyz/idled" --no-headers -o=custom-columns=NAME:.metadata.name,NS:.metadata.namespace,REPLICAS:.spec.replicas | while read -r DEPLOY
do
    replicas=`echo $DEPLOY | cut -d' ' -f3`
    if [ ! "$replicas" = "0" ]; then
        ns=`echo $DEPLOY | cut -d' ' -f2`
        deploy=`echo $DEPLOY | cut -d' ' -f1`

        kubectl --namespace=${ns} patch deployment ${deploy} --type='json' -p="[{\"op\": \"remove\", \"path\": \"/metadata/labels/mojanalytics.xyz~1idled\"}]" && echo "Removed 'mojanalytics.xyz/idled' label from Deployment '$deploy' in namespace '${ns}' '"
    fi

done;
