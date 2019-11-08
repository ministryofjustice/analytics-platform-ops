#!/usr/bin/env bash

# Generic script that sets the image+tag of a container in a deployment's pod spec in user namespaces
# As is.  Will set deployment's "r-studio-server" container's image tag to "v1.3.2" in all user namespaces

set -e

DRY_RUN=true

while true; do
	read -p "Is this a DRY RUN? i.e. NO-OP [y/N]: " dry_run
	case $dry_run in
	    [y]*    ) DRY_RUN=true; break;;
	    [N]*    ) DRY_RUN=false; break;;
	    *       ) echo "Answer y to simulate the operation.  Answer N to perform the operation."; exit;;
    esac
done

APP=rstudio
TAG=v1.3.2
POD_CONTAINER=r-studio-server
NAMESPACES=$(kubectl get ns | grep user- | grep -v user-init-platform | cut -f1 -d' ')



for ns in $NAMESPACES; do

	kubectl set image deployments -l app=$APP $POD_CONTAINER=quay.io/mojanalytics/$APP:$TAG \
	--namespace $ns \
	--dry-run=$DRY_RUN

done
