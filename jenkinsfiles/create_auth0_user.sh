#!/usr/bin/env bash
set -ex


# ENVIRONMENT VARIABLES

# AUTH0_DOMAIN=<YOUR_AUTH0_DOMAIN>
# AUTH0_CLIENT_ID=<YOUR_CLIENT_ID>
# AUTH0_CLIENT_SECRET=<YOUR_CLIENT_SECRET>


# INPUT

USER_EMAIL=$1
if [ -z $USER_EMAIL ]; then
  echo "Usage: create_auth0_users USER_EMAIL"
  exit 1
fi


# FUNCTIONS

function authenticate {
  local payload=$(cat <<-EOF
{
  "client_id": "$AUTH0_CLIENT_ID",
  "client_secret": "$AUTH0_CLIENT_SECRET",
  "audience": "https://$AUTH0_DOMAIN/api/v2/",
  "grant_type": "client_credentials"
}
EOF)

  curl -v --request POST \
    --url https://${AUTH0_DOMAIN}/oauth/token \
    --header 'content-type: application/json' \
    --data "$payload"
}

function auth_token {
  authenticate | jq -r '.access_token'
}

function create_user {
  local auth_token=$1
  local email=$2

  local payload=$(cat <<-EOF
{
  "email": "$email",
  "connection": "email",
  "email_verified": true
}
EOF)

  curl -v --request POST \
    --url https://${AUTH0_DOMAIN}/api/v2/users \
    --header "Authorization: Bearer $auth_token" \
    --header 'content-type: application/json' \
    --data "$payload"
}


# MAIN

AUTH0_TOKEN=$(auth_token)
create_user $AUTH0_TOKEN $USER_EMAIL
