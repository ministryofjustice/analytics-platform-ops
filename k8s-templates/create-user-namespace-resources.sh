#!/bin/bash
set -ex

for f in user-base/user-namespace/*
do
    cat $f \
    | sed -e s/{{.Username}}/kerin/g \
    | kubectl apply -f -
done
