#!/usr/bin/env bash

set -ex

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 3 ] || die "3 arguments required, $# provided"
USERNAME=$1
PASSWORD=$2
ES_URL=$3

for TEMPLATE in templates/*; do
    INDEX=$(basename $TEMPLATE | cut -f 1 -d '.')

    curl -XPUT -u $USERNAME:$PASSWORD "$ES_URL/_template/$INDEX" \
        -H "Content-Type: application/json" -d @$TEMPLATE
done
