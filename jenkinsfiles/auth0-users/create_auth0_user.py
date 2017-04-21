#!/usr/bin/env python3

# Authorization Extension API doc: https://kerinmoj.eu.webtask.io/adf6e2f2b84784b57522e3b19dfc9201/configuration/api

from group_api import GroupAPI
from role_api import RoleAPI
from permission_api import PermissionAPI

import argparse
import requests
import logging
from auth0.v3.authentication import GetToken
from auth0.v3.management import Auth0


ROLE_NAME = 'app-viewer'
PERMISSION_NAME = 'view:app'

logging.basicConfig()
LOG = logging.getLogger(__name__)
LOG.setLevel(logging.DEBUG)


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


def get_auth0_client(domain, client_id, client_secret):
    # get management API token
    get_token = GetToken(domain)
    token = get_token.client_credentials(client_id, client_secret,
                                         'https://{}/api/v2/'.format(domain))
    mgmt_api_token = token['access_token']

    # Return Auth0 API client
    return Auth0(domain, mgmt_api_token)


def create_passwordless_user(auth0_client, email):
    users_list = auth0_client.users.list(
        search_engine='v2',
        q='identities.connection:"email" AND email:"{}"'.format(email)
    )

    if users_list['length'] > 0:
        # return existing user
        user = users_list['users'][0]
        LOG.info("User already exists = {}".format(user))
        return user
    else:
        # create new user
        user = auth0_client.users.create({
            "email": email,
            "connection": "email",
            "email_verified": True
        })
        LOG.info("User created = {}".format(user))
        return user


def get_app(auth0_client, app_name):
    apps = auth0_client.clients.all()
    for app in apps:
        if app['name'] == app_name:
            LOG.debug("App found = {}".format(app))
            return app
    LOG.critical("App with name '{}' not found".format(app_name))


def get_authz_token(domain, client_id, client_secret):
    get_token = GetToken(domain)
    credentials = get_token.client_credentials(
        client_id, client_secret, 'urn:auth0-authz-api'
    )

    return credentials['access_token']


def process(domain, client_id, client_secret, authz_api, app_name, email):
    # create API client
    auth0 = get_auth0_client(domain, client_id, client_secret)

    # get authorization extension token
    authz_token = get_authz_token(domain, client_id, client_secret)

    user = create_passwordless_user(auth0, email)
    user_id = user['user_id']

    # Get shiny app by name
    app = get_app(auth0, app_name)
    app_id = app['client_id']

    permission_api = PermissionAPI(authz_api, authz_token, LOG)
    permission = permission_api.create(app_id, PERMISSION_NAME)

    role_api = RoleAPI(authz_api, authz_token, LOG)
    role = role_api \
        .create(app_id, ROLE_NAME) \
        .add_permission(permission.id())
    role_id = role.id()

    group_api = GroupAPI(authz_api, authz_token, LOG)
    group = group_api \
        .create(app_name) \
        .add_role(role_id) \
        .add_user(user_id)


if __name__ == '__main__':
    import sys
    sys.exit(main())
