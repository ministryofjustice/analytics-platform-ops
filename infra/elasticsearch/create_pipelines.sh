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

for PIPELINE in pipelines/*; do
    NAME=$(basename $PIPELINE | cut -f 1 -d '.')

    curl -XPUT -u $USERNAME:$PASSWORD "$ES_URL/ingest/pipeline/$NAME" \
        -H "Content-Type: application/json" -d @$PIPELINE
done
