#!/bin/bash
set -ex

for f in user-base/default-namespace/*
do
    cat $f \
    | sed -e s/{{.Username}}/kerin/g \
            -e s/{{.EFSHostname}}/fs-673efbae.efs.eu-west-1.amazonaws.com/g \
    | kubectl apply -f -
done
