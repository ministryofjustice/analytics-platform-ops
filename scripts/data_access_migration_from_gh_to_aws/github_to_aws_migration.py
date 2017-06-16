#! /usr/bin/env python3

import json
import os

import boto3
from github import Github


GITHUB_ORG = os.environ.get("GITHUB_ORG", "moj-analytical-services")
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
STAGE = os.environ.get("STAGE", "dev")


def main():
    github = Github(GITHUB_TOKEN)
    org = github.get_organization(GITHUB_ORG)

    for member in org.get_members():
        create_user_role(member.login)

    for team in org.get_teams():
        create_team_bucket(team.slug)
        for member in team.get_members():
            attach_bucket_policy(team.slug, member.login)


def create_user_role(username):
    invoke_lambda("create_user_role", {"username": username})


def create_team_bucket(slug):
    payload = {"team": {"slug": slug}}
    invoke_lambda("create_team_bucket", payload)
    invoke_lambda("create_team_bucket_policies", payload)


def attach_bucket_policy(team_slug, username, policy_type="readwrite"):
    payload = {
        "user": {"username": username},
        "team": {"slug": team_slug},
        "policy": {"type": policy_type},
    }
    invoke_lambda("attach_bucket_policy", payload)


def invoke_lambda(function, payload):
    fn_name = "{}_{}".format(STAGE, function)
    print("Invoking '{}' with {}...".format(fn_name, json.dumps(payload)))

    client = boto3.client("lambda")
    client.invoke(
        FunctionName=fn_name,
        Payload=json.dumps(payload).encode("utf8"),
        InvocationType="RequestResponse",
    )


if __name__ == "__main__":
    main()
