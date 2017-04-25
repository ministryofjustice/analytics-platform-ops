#!/usr/bin/env python3

# Authorization Extension API doc:
# https://kerinmoj.eu.webtask.io/adf6e2f2b84784b57522e3b19dfc9201/configuration/api

import argparse
import logging

import requests
from auth0.v3.authentication import GetToken
from auth0.v3.management import Auth0

from group_api import GroupAPI
from permission_api import PermissionAPI
from role_api import RoleAPI


ROLE_NAME = 'app-viewer'
PERMISSION_NAME = 'view:app'

logging.basicConfig()
LOG = logging.getLogger(__name__)
LOG.setLevel(logging.DEBUG)


def main():
    args = get_args()

    # create API client
    auth0_client = get_auth0_client(
        args.domain,
        args.client_id,
        args.client_secret,
    )

    # get authorization extension token
    authz_token = get_token(
        args.domain,
        args.client_id,
        args.client_secret,
        'urn:auth0-authz-api',
    )

    user = create_passwordless_user(auth0_client, args.email)

    # Get shiny app by name
    app = get_app(auth0_client, args.app_name)
    app_id = app['client_id']

    permission_api = PermissionAPI(args.authz_api, authz_token)
    permission = permission_api.create(app_id, PERMISSION_NAME)

    role_api = RoleAPI(args.authz_api, authz_token)
    role = role_api.create(app_id, ROLE_NAME)
    role.add_permission(permission.id())

    group_api = GroupAPI(args.authz_api, authz_token)
    group = group_api.create(args.app_name)
    group.add_role(role.id())
    group.add_user(user['user_id'])


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('domain', help="Auth0 domain")
    parser.add_argument('client_id', help="Auth0 client ID")
    parser.add_argument('client_secret', help="Auth0 client secret")
    parser.add_argument('authz_api', help="Authorization API URL")
    parser.add_argument('app_name', help="App client name")
    parser.add_argument('email', help="User email")

    return parser.parse_args()


def get_token(domain, client_id, client_secret, audience):
    """
    Gets Auth0 token

    Args:
        domain (string): Auth0 domain
        client_id (string): Auth0 client_id
        client_secret (string): Auth0 client_secret
        audience (string): what the token will be used for

    Returns:
        Auth0 token (string)
    """

    token_api = GetToken(domain)
    credentials = token_api.client_credentials(
        client_id,
        client_secret,
        audience,
    )

    return credentials['access_token']


def get_auth0_client(domain, client_id, client_secret):
    """
    Gets Auth0 client

    Args:
        domain (string): Auth0 domain
        client_id (string): Auth0 client_id
        client_secret (string): Auth0 client_secret

    Returns:
        Auth0 client (auth0.v3.management.Auth0)
    """

    # Get management API token
    token = get_token(
        domain,
        client_id,
        client_secret,
        'https://{}/api/v2/'.format(domain)
    )

    # Return Auth0 API client
    return Auth0(domain, token)


def create_passwordless_user(auth0_client, email):
    """
    Creates an Auth0 user with 'email' connection (passwordless)

    Checks if the user already exists first.

    Args:
        auth0_client (auth0.v3.management.Auth0): Auth0 client
        email (string): email address of the user to create

    Returns:
        user (dictionary)

    Required scopes:
        * ``read:users``
        * ``create:users``
    """

    users_list = auth0_client.users.list(
        search_engine='v2',
        q='identities.connection:"email" AND email:"{}"'.format(email)
    )

    user = None
    if users_list['length'] > 0:
        # return existing user
        user = users_list['users'][0]
        LOG.info("User already exists = {}".format(user))
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
    """
    Gets the Auth0 client by name

    Args:
        auth0_client (auth0.v3.management.Auth0): Auth0 client
        app_name (string): client name to get

    Returns:
        client (dictionary) or raises an exception if not found

    Required scopes:
        * ``read:clients``
    """

    apps = auth0_client.clients.all()
    for app in apps:
        if app['name'] == app_name:
            LOG.debug("App found = {}".format(app))
            return app

    msg = "App with name '{}' not found".format(app_name)
    LOG.critical(msg)
    raise Exception(msg)


if __name__ == '__main__':
    main()
