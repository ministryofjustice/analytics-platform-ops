#!/usr/bin/env bash

set -eu -o pipefail

DOMAIN=$1

# During propagation DNS records can appear and disappear, so check
# DNS resolves for a number of successive checks so we're really sure

COUNTER=0
while [[ $COUNTER -lt 20 ]]
do
    NUM_RECORDS=$(dig ns $DOMAIN +short | wc -l | awk '{print $1}')

    if [[ $NUM_RECORDS == "0" ]]
    then
        COUNTER=0
    elif [[ $NUM_RECORDS == "4" ]]
    then
        COUNTER=$((COUNTER+1))
    fi

    sleep 3
done
