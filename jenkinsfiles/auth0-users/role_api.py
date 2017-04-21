from role import Role

import requests


class RoleAPI(object):

    def __init__(self, authz_api, authz_token, logger):
        self.authz_api = authz_api
        self.authz_token = authz_token
        self.log = logger

    def create(self, app_id, role_name):
        role_data = self._get_role(app_id, role_name)
        if not role_data:
            role_data = self._create_role(app_id, role_name)

        return Role(self.authz_api, self.authz_token, self.log, role_data)

    def _get_all(self):
        # Get existing roles
        resp = requests.get(
            '{}/roles'.format(self.authz_api),
            headers={
                "Authorization": "Bearer {}".format(self.authz_token)
            }
        )
        if resp.status_code != 200:
            self.log.error("Failed to get roles: expected 200, got {}: {}".format(resp.status_code, resp.text))
            return None

        return resp.json()['roles']


    def _get_role(self, app_id, role_name):
        roles = self._get_all()
        for role in roles:
            if role['applicationId'] == app_id and role['name'] == role_name:
                return role
        return None


    def _create_role(self, app_id, role_name):
        # Create new role
        resp = requests.post(
            '{}/roles'.format(self.authz_api),
            headers={
                "Authorization": "Bearer {}".format(self.authz_token),
            },
            json={
              'name': role_name,
              'description': role_name,
              'applicationId': app_id,
              'applicationType': "client",
            }
        )
        if resp.status_code != 200:
            self.log.error("Failed to create role: expected 200, got {}: {}".format(resp.status_code, resp.text))
            return None

        role = resp.json()

        self.log.debug("Role created = {}".format(role))
        return role
