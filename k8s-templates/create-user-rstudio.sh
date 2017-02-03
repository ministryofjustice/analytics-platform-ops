#!/bin/bash
set -ex

for f in r-studio-user/*
do
    cat $f \
    | sed \
        -e s/{{.Username}}/kerin/g \
        -e s/{{.ClientSecretB64}}/bF9oWUNwWk55a3NObElYRVZXdmRRT2VKaDZzTjFyeUN4N2Q2ZFhoTV9YUWp2cEZIUDlKa3VVLUVyU2tNWnpTcg==/g \
        -e s/{{.ClientIDB64}}/MnkzRmRobldTR25YNkw2cGR0Qktra083V1RURUR6TG8=/g \
        -e s/{{.DomainB64}}/a2VyaW5tb2ouZXUuYXV0aDAuY29t/g \
        -e s/{{.CallbackURLB64}}/aHR0cHM6Ly9rZXJpbi5yLXN0dWRpby1ucy51c2Vycy5hbmFseXRpY3Mua29wcy5pbnRlZ3JhdGlvbi5kc2QuaW8vY2FsbGJhY2s=/g \
        -e s/{{.CookieSecretB64}}/QzhCN0I2RjEtNDVDMi00ODdGLUI5QjUtQThCRDhBRjg0RDAw/g \
    | kubectl apply -n user-kerin -f -
done
