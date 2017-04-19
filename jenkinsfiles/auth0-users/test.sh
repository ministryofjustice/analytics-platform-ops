#!/bin/bash

access_token=$(
    curl -s --request POST \
      --url https://kerinmoj.eu.auth0.com/oauth/token \
      --header 'content-type: application/json' \
      --data '{"client_id":"VMO5b8qcFOQ5cBAqMutzvHDjRo21NliL","client_secret":"FPneykUbWTE3lMz2LyV0OQCaK9oQcE8QV2-vYgEM9ffus_c92uCE25to5jg0nnvC","audience":"urn:auth0-authz-api","grant_type":"client_credentials"}' \
    | jq -r .access_token
)

curl --request GET \
  --url https://kerinmoj.eu.webtask.io/adf6e2f2b84784b57522e3b19dfc9201/api/groups \
  --header "Authorization: Bearer $access_token"
