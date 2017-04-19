#!/usr/bin/env python3

import argparse
import requests
from auth0.v3.authentication import GetToken
from auth0.v3.management import Auth0


def main():
    args = get_args()
    process(args.domain, args.client_id, args.client_secret, args.authz_api,
            args.app_name, args.email)


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('domain', help="Auth0 domain")
    parser.add_argument('client_id', help="Auth0 client ID")
    parser.add_argument('client_secret', help="Auth0 client secret")
    parser.add_argument('authz_api', help="Authorization API URL")
    parser.add_argument('app_name', help="App client name")
    parser.add_argument('email', help="User email")

    return parser.parse_args()


def process(domain, client_id, client_secret, authz_api, app_name, email):
    # get management API token
    get_token = GetToken(domain)
    token = get_token.client_credentials(client_id, client_secret,
                                         'https://{}/api/v2/'.format(domain))
    mgmt_api_token = token['access_token']

    # create API client
    auth0 = Auth0(domain, mgmt_api_token)

    # Check if user already exists, create if not
    search_results = auth0.users.list(
        search_engine='v2',
        q='identities.connection:"email" AND email:"{}"'.format(email)
    )

    if search_results['length'] == 0:
        auth0.users.create({
            "email": email,
            "connection": "email",
            "email_verified": True
        })

    # get authorization extension token
    token = get_token.client_credentials(client_id, client_secret,
                                         'urn:auth0-authz-api')
    authz_token = token['access_token']

    # Get all existing groups
    r = requests.get(
        '{}/groups'.format(authz_api),
        headers={
            "Authorization": "Bearer {}".format(authz_token)
        }
    )

    app_names = []
    for g in r.json()['groups']:
        app_names.append(g['name'])

    # Create group if it doesn't already exist
    if app_name not in app_names:
        r = requests.post(
            '{}/groups'.format(authz_api),
            headers={
                "Authorization": "Bearer {}".format(authz_token)
            },
            data={
                'name': app_name,
                'description': app_name
            }
        )
        print(r.json())

    # Get existing permissions
    r = requests.get(
        '{}/permissions'.format(authz_api),
        headers={
            "Authorization": "Bearer {}".format(authz_token)
        }
    )
    print(r.json())


if __name__ == '__main__':
    import sys
    sys.exit(main())
