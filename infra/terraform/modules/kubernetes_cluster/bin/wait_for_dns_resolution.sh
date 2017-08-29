#!/usr/bin/env bash

set -eu -o pipefail

DOMAIN=$1

# During propagation DNS records can appear and disappear, so make sure
# we get three positive hits before proceeding

COUNTER=0
while [[ $COUNTER -lt 3 ]]
do
    if [[ $(dig ns $DOMAIN +short | wc -l | awk '{print $1}') == "4" ]]
    then
        COUNTER=$((COUNTER+1))
    fi

    sleep 5
done
