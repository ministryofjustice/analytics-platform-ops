#!/usr/bin/env bash

set -eu -o pipefail

DOMAIN=$1

# Wait until kops reports cluster ready
until kops validate cluster $DOMAIN > /dev/null 2>&1
do
    sleep 5
done
