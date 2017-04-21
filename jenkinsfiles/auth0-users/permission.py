import requests


class Permission(object):

    def __init__(self, authz_api, authz_token, logger, permission_data):
        if not permission_data:
            raise ValueError("permission_data can't be empty")

        self.authz_api = authz_api
        self.authz_token = authz_token
        self.data = permission_data
        self.log = logger

    def id(self):
        return self.data["_id"]
