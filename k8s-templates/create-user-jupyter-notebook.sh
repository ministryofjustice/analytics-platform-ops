#!/bin/bash
set -ex

for f in jupyter-notebook/*
do
    cat $f \
    | sed \
        -e s/{{.Username}}/xoen/g \
        -e s/{{.ClientSecretB64}}/${CLIENT_SECRET}/g \
        -e s/{{.ClientIDB64}}/${TOOLS_ID}/g \
        -e s/{{.DomainB64}}/${DOMAIN}/g \
        -e s/{{.CallbackURLB64}}/${CALLBACK_URL}/g \
        -e s/{{.CookieSecretB64}}/${COOKIE_SECRET}/g \
        -e s/{{.ToolsDomain}}/${TOOLS_DOMAIN}/g \
        -e s/{{.AWSAccessKeyIDB64}}/${AWS_ACCESS_KEY_ID}/g \
        -e s/{{.AWSSecretAccessKeyB64}}/${AWS_SECRET_ACCESS_KEY}/g \
    | kubectl apply -n user-xoen -f -
done
