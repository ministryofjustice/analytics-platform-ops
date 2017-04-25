import logging

import requests

from group import Group


logging.basicConfig()
LOG = logging.getLogger(__name__)
LOG.setLevel(logging.DEBUG)


class GroupAPI(object):

    def __init__(self, authz_api, authz_token):
        self.authz_api = authz_api
        self.authz_token = authz_token

    def create(self, group_name):
        group_data = self._get_group(group_name)
        if not group_data:
            group_data = self._create_group(group_name)

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

    def _create_group(self, group_name):
        # Create new group
        resp = requests.post(
            '{}/groups'.format(self.authz_api),
            headers={
                "Authorization": "Bearer {}".format(self.authz_token),
            },
            json={
                'name': group_name,
                'description': group_name,
            }
        )
        if resp.status_code != 200:
            msg = "Failed to create group: expected 200, got {}: {}".format(
                resp.status_code, resp.text)
            LOG.error(msg)
            raise Exception(msg)

        group = resp.json()
        LOG.debug("Group created = {}".format(group))
        return group
