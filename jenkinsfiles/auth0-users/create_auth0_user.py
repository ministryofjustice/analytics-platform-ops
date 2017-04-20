#!/usr/bin/env python3

# Authorization Extension API doc: https://kerinmoj.eu.webtask.io/adf6e2f2b84784b57522e3b19dfc9201/configuration/api

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


def create_permission(authz_api, authz_token, app_id, permission_name):
    # Get existing permissions
    resp = requests.get(
        '{}/permissions'.format(authz_api),
        headers={
            "Authorization": "Bearer {}".format(authz_token)
        }
    )
    if resp.status_code != 200:
        LOG.debug("Failed to get permissions: expected 200, got {}: {}".format(resp.status_code, resp.text))
        return None
    permissions = resp.json()
    permission = None
    # Check if permission already exists
    for p in permissions['permissions']:
        if p['applicationId'] == app_id and p['name'] == permission_name:
            permission = p
            break
    if permission:
        # Return existing permission
        LOG.debug("Permission already exists = {}".format(permission))
        return permission

    # Create new permission
    resp = requests.post(
        '{}/permissions'.format(authz_api),
        headers={
            "Authorization": "Bearer {}".format(authz_token)
        },
        json={
          'name': permission_name,
          'description': permission_name,
          'applicationId': app_id,
          'applicationType': 'client',
        }
    )
    if resp.status_code != 200:
        LOG.error("Failed to create permission: expected 200, got {}: {}".format(resp.status_code, resp.text))
        return None
    permission = resp.json()

    LOG.debug("Permission created = {}".format(permission))
    return permission

def create_role(authz_api, authz_token, app_id, role_name):
    # Get existing roles
    resp = requests.get(
        '{}/roles'.format(authz_api),
        headers={
            "Authorization": "Bearer {}".format(authz_token)
        }
    )
    if resp.status_code != 200:
        LOG.error("Failed to get roles: expected 200, got {}: {}".format(resp.status_code, resp.text))
        return None

    roles = resp.json()

    # Check if role already exists
    role = None
    for r in roles['roles']:
        if r['applicationId'] == app_id and r['name'] == role_name:
            role = r
            break
    if role:
        # Return existing role
        LOG.debug("Role already exists = {}".format(role))
        return role

    # Create new role
    resp = requests.post(
        '{}/roles'.format(authz_api),
        headers={
            "Authorization": "Bearer {}".format(authz_token),
        },
        json={
          'name': role_name,
          'description': role_name,
          'applicationId': app_id,
          'applicationType': "client",
        }
    )
    if resp.status_code != 200:
        LOG.error("Failed to create role: expected 200, got {}: {}".format(resp.status_code, resp.text))
        return None

    role = resp.json()

    LOG.debug("Role created = {}".format(role))
    return role


def add_permission_to_role(authz_api, authz_token, role, permission_id):
    payload = {
        'name': role['name'],
        'description': role['description'],
        'applicationId': role['applicationId'],
        'applicationType': role['applicationType'],
        'permissions': role['permissions'],
    }
    # Authorization Extension doesn't check for duplicated permissions
    if permission_id not in payload['permissions']:
        payload['permissions'].append(permission_id)

    # Update the role
    resp = requests.put(
        '{}/roles/{}'.format(authz_api, role['_id']),
        headers={
            "Authorization": "Bearer {}".format(authz_token)
        },
        json=payload,
    )
    if resp.status_code != 200:
        LOG.error("Failed to add permission ({}) to role ({}): expected 200, got {}: {}".format(permission_id, role['_id'], resp.status_code, resp.text))
        return None

    LOG.debug("Permission ({}) added to role ({})".format(permission_id, role['_id']))
    return resp.json()


def create_group(authz_api, authz_token, group_name, role_id):
    # Get existing roles
    resp = requests.get(
        '{}/groups'.format(authz_api),
        headers={
            "Authorization": "Bearer {}".format(authz_token)
        }
    )
    if resp.status_code != 200:
        LOG.error("Failed to get groups: expected 200, got {}: {}".format(resp.status_code, resp.text))
        return None

    groups = resp.json()

    # Check if group already exists
    group = None
    for g in groups['groups']:
        if g['name'] == group_name:
            group = g
            break
    if group:
        # Return existing group
        LOG.debug("Group already exists = {}".format(group))
        return group

    # Create new group
    resp = requests.post(
        '{}/groups'.format(authz_api),
        headers={
            "Authorization": "Bearer {}".format(authz_token),
        },
        json={
          'name': group_name,
          'description': group_name,
        }
    )
    if resp.status_code != 200:
        LOG.error("Failed to create group: expected 200, got {}: {}".format(resp.status_code, resp.text))
        return None
    group = resp.json()

    LOG.debug("Group created = {}".format(group))
    return group


def add_role_to_group(authz_api, authz_token, group, role_id):
    group_id = group['_id']

    # Update the group
    resp = requests.patch(
        '{}/groups/{}/roles'.format(authz_api, group_id),
        headers={
            "Authorization": "Bearer {}".format(authz_token)
        },
        json=[role_id],
    )
    if resp.status_code != 204:
        LOG.error("Failed to add role ({}) to group ({}): expected 204, got {}: {}".format(role_id, group_id, resp.status_code, resp.text))
        return None

    LOG.debug("Role ({}) added to group ({})".format(role_id, group_id))
    return group


def add_user_to_group(authz_api, authz_token, group, user_id):
    group_id = group['_id']
    # Update the group
    resp = requests.patch(
        '{}/groups/{}/members'.format(authz_api, group_id),
        headers={
            "Authorization": "Bearer {}".format(authz_token)
        },
        json=[user_id],
    )
    if resp.status_code != 204:
        LOG.error("Failed to add user ({}) to group ({}): expected 204, got {}: {}".format(user_id, group_id, resp.status_code, resp.text))
        return None

    LOG.debug("User ({}) added to group ({})".format(user_id, group_id))
    return group


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

    permission = create_permission(authz_api, authz_token, app_id, PERMISSION_NAME)
    permission_id = permission['_id']

    role = create_role(authz_api, authz_token, app_id, ROLE_NAME)
    role = add_permission_to_role(authz_api, authz_token, role, permission_id)
    role_id = role['_id']

    group = create_group(authz_api, authz_token, app_name, role_id)
    group = add_role_to_group(authz_api, authz_token, group, role_id)
    group = add_user_to_group(authz_api, authz_token, group, user_id)


if __name__ == '__main__':
    import sys
    sys.exit(main())
