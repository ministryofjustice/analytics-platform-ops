import logging

import requests


logging.basicConfig()
LOG = logging.getLogger(__name__)
LOG.setLevel(logging.DEBUG)


class Role(object):
    """
    Auth0 Authorization Extension's Role
    """

    def __init__(self, authz_api, authz_token, role_data):
        if not role_data:
            raise Exception("role_data can't be empty")

        self.authz_api = authz_api
        self.authz_token = authz_token
        self.data = role_data

    def id(self):
        return self.data["_id"]

    def name(self):
        return self.data["name"]

    def description(self):
        return self.data["description"]

    def application_id(self):
        return self.data["applicationId"]

    def application_type(self):
        return self.data["applicationType"]

    def permission_ids(self):
        return self.data["permissions"]

    def add_permission(self, permission_id):
        """
        Adds permission to the role

        Raises an exception if it can't.

        Args:
            permission_id (string): ID of the permission to add

        Required scopes:
            * ``read:roles``
            * ``update:roles``
        """

        payload = {
            'name': self.name(),
            'description': self.description(),
            'applicationId': self.application_id(),
            'applicationType': self.application_type(),
            'permissions': self.permission_ids(),
        }
        # Authorization Extension doesn't check for duplicated permissions
        if permission_id not in payload['permissions']:
            payload['permissions'].append(permission_id)

        # Update the role
        resp = requests.put(
            '{}/roles/{}'.format(self.authz_api, self.id()),
            headers={
                "Authorization": "Bearer {}".format(self.authz_token)
            },
            json=payload,
        )
        if resp.status_code != 200:
            msg = "Failed to add permission ({}) to role ({}): expected 200, got {}: {}".format(
                permission_id, self.id(), resp.status_code, resp.text)
            LOG.error(msg)
            raise Exception(msg)

        LOG.debug("Permission ({}) added to role ({})".format(
            permission_id, self.id()))
        self.data = resp.json()
