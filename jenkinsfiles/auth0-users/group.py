import requests
import logging


logging.basicConfig()
LOG = logging.getLogger(__name__)
LOG.setLevel(logging.DEBUG)


class Group(object):

    def __init__(self, authz_api, authz_token, group_data):
        if not group_data:
            raise ValueError("group_data can't be empty")

        self.authz_api = authz_api
        self.authz_token = authz_token
        self.data = group_data

    def id(self):
        return self.data["_id"]

    def add_role(self, role_id):
        # Update the group
        resp = requests.patch(
            '{}/groups/{}/roles'.format(self.authz_api, self.id()),
            headers={
                "Authorization": "Bearer {}".format(self.authz_token)
            },
            json=[role_id],
        )
        if resp.status_code != 204:
            LOG.error("Failed to add role ({}) to group ({}): expected 204, got {}: {}".format(role_id, self.id(), resp.status_code, resp.text))
            return None

        LOG.debug("Role ({}) added to group ({})".format(role_id, self.id()))
        return self


    def add_user(self, user_id):
        # Update the group
        resp = requests.patch(
            '{}/groups/{}/members'.format(self.authz_api, self.id()),
            headers={
                "Authorization": "Bearer {}".format(self.authz_token)
            },
            json=[user_id],
        )
        if resp.status_code != 204:
            LOG.error("Failed to add user ({}) to group ({}): expected 204, got {}: {}".format(user_id, self.id(), resp.status_code, resp.text))
            return None

        LOG.debug("User ({}) added to group ({})".format(user_id, self.id()))
        return self
