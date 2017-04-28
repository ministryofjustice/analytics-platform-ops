import logging

import requests


logging.basicConfig()
LOG = logging.getLogger(__name__)
LOG.setLevel(logging.WARNING)


class Group(object):
    """
    Auth0 Authorization Extension's Group
    """

    def __init__(self, authz_api, authz_token, group_data):
        if not group_data:
            raise Exception("group_data can't be empty")

        self.authz_api = authz_api
        self.authz_token = authz_token
        self.data = group_data

    def id(self):
        return self.data["_id"]

    def add_role(self, role_id):
        """
        Adds role to the group

        Raises an exception if it can't.

        Args:
            role_id (string): ID of the role to add

        Required scopes:
            * ``read:groups``
            * ``update:groups``
        """

        endpoint = '{}/groups/{}/roles'.format(self.authz_api, self.id())

        if not self._add_child(endpoint, self.authz_token, role_id):
            msg = "Failed to add role ({}) to group ({})".format(
                role_id, self.id())
            LOG.error(msg)
            raise Exception(msg)

        LOG.debug("Role ({}) added to group ({})".format(role_id, self.id()))

    def add_user(self, user_id):
        """
        Adds user to the group

        Raises an exception if it can't.

        Args:
            user_id (string): ID of the user to add

        Required scopes:
            * ``read:groups``
            * ``update:groups``
        """

        endpoint = '{}/groups/{}/members'.format(self.authz_api, self.id())

        if not self._add_child(endpoint, self.authz_token, user_id):
            msg = "Failed to add user ({}) to group ({})".format(
                user_id, self.id())
            LOG.error(msg)
            raise Exception(msg)

        LOG.debug("User ({}) added to group ({})".format(user_id, self.id()))


    def _add_child(self, endpoint, authz_token, child_id):
        resp = requests.patch(
            endpoint,
            headers={
                "Authorization": "Bearer {}".format(self.authz_token)
            },
            json=[child_id],
        )
        if resp.status_code != 204:
            LOG.error("Request failed: expected 204, got {}: PATCH {} failed: {}".format(
                resp.status_code, endpoint, resp.text
            ))
            return False
        else:
            return True
