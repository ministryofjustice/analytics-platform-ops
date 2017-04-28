import logging

import requests

from group import Group


logging.basicConfig()
LOG = logging.getLogger(__name__)
LOG.setLevel(logging.WARNING)


class GroupAPI(object):
    """
    Auth0 Authorization Extension's Group API abstraction
    """

    def __init__(self, authz_api, authz_token):
        self.authz_api = authz_api
        self.authz_token = authz_token

    def get(self, group_name):
        """
        Returns the group with group_name name

        Args:
            group_name (string): name of the group to get

        Returns:
            group (Group) or raises an exception

        Required scopes:
            * ``read:groups``
        """
        group_data = self._get_group(group_name)
        if not group_data:
            msg = "Group with name '{}' not found.".format(
                group_name)
            LOG.error(msg)
            raise Exception(msg)

        msg = "Group with name '{}' found: {}".format(
                group_name, group_data)
        LOG.debug(msg)
        return Group(self.authz_api, self.authz_token, group_data)

    def _get_all(self):
        # Get existing groups
        resp = requests.get(
            '{}/groups'.format(self.authz_api),
            headers={
                "Authorization": "Bearer {}".format(self.authz_token)
            }
        )
        if resp.status_code != 200:
            msg = "Failed to get groups: expected 200, got {}: {}".format(
                resp.status_code, resp.text)
            LOG.error(msg)
            raise Exception(msg)

        return resp.json()['groups']

    def _get_group(self, group_name):
        groups = self._get_all()
        for group in groups:
            if group['name'] == group_name:
                return group
