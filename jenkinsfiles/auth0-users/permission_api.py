import logging

import requests

from permission import Permission


logging.basicConfig()
LOG = logging.getLogger(__name__)
LOG.setLevel(logging.DEBUG)


class PermissionAPI(object):

    def __init__(self, authz_api, authz_token):
        self.authz_api = authz_api
        self.authz_token = authz_token

    def create(self, app_id, permission_name):
        permission_data = self._get_permission(app_id, permission_name)
        if not permission_data:
            permission_data = self._create_permission(app_id, permission_name)

        return Permission(self.authz_api, self.authz_token, permission_data)

    def _get_permission(self, app_id, permission_name):
        permissions = self._get_all()
        for permission in permissions:
            if permission['applicationId'] == app_id and permission['name'] == permission_name:
                return permission

    def _get_all(self):
        # Get existing permissions
        resp = requests.get(
            '{}/permissions'.format(self.authz_api),
            headers={
                "Authorization": "Bearer {}".format(self.authz_token)
            }
        )
        if resp.status_code != 200:
            msg = "Failed to get permissions: expected 200, got {}: {}".format(
                resp.status_code, resp.text)
            LOG.error(msg)
            raise Exception(msg)

        return resp.json()['permissions']

    def _create_permission(self, app_id, permission_name):
        # Create new permission
        resp = requests.post(
            '{}/permissions'.format(self.authz_api),
            headers={
                "Authorization": "Bearer {}".format(self.authz_token)
            },
            json={
                'name': permission_name,
                'description': permission_name,
                'applicationId': app_id,
                'applicationType': 'client',
            }
        )
        if resp.status_code != 200:
            msg = "Failed to create permission: expected 200, got {}: {}".format(
                resp.status_code, resp.text)
            LOG.error(msg)
            raise Exception(msg)

        permission = resp.json()
        LOG.debug("Permission created = {}".format(permission))
        return permission
