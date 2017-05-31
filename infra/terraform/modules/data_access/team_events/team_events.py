'''
Environment variables:
- LAMBDA_CREATE_TEAM_BUCKET_ARN, ARN of the lambda function to create the
  S3 bucket for the team
- LAMBDA_CREATE_TEAM_BUCKET_POLICIES_ARN, ARN of the lambda function to
  create the policies for the team S3 bucket
- LAMBDA_DELETE_TEAM_BUCKET_POLICIES_ARN, ARN of the lambda function to
  delete the policies for the team S3 bucket
- LOG_LEVEL, change the logging level (default is "DEBUG"). Must be one of
  the python logging supported levels: "CRITICAL", "ERROR", "WARNING",
  "INFO" or "DEBUG" (See: https://docs.python.org/2/library/logging.html#logging-levels)
'''

import json
import logging
import os

import boto3


LOG = logging.getLogger(__name__)
LOG_LEVEL = os.environ.get("LOG_LEVEL", "DEBUG")
LOG.setLevel(LOG_LEVEL)


def event_received(sns_event, context):
    LOG.debug("SNS event received = {}".format(json.dumps(sns_event)))
    for record in sns_event["Records"]:
        event = json.loads(record["Sns"]["Message"])
        action = event["action"]

        if action == "created":
            team_created(event)
        elif action == "deleted":
            team_deleted(event)


def team_created(event):
    LOG.debug("Handling team 'created' event: {}".format(json.dumps(event)))

    invoke_lambda(
        function=os.environ["LAMBDA_CREATE_TEAM_BUCKET_ARN"],
        payload=team_payload(event),
    )

    invoke_lambda(
        function=os.environ["LAMBDA_CREATE_TEAM_BUCKET_POLICIES_ARN"],
        payload=team_payload(event),
    )


def team_deleted(event):
    LOG.debug("Handling team 'deleted' event: {}".format(json.dumps(event)))

    invoke_lambda(
        function=os.environ["LAMBDA_DELETE_TEAM_BUCKET_POLICIES_ARN"],
        payload=team_payload(event),
    )


def team_payload(event):
    return {
        "team": {
            "slug": event["team"]["slug"]
        }
    }


def invoke_lambda(function, payload):
    LOG.debug("Invoking '{function}' with payload: {payload}".format(
        function=function,
        payload=json.dumps(payload)),
    )

    client = boto3.client("lambda")
    client.invoke(
        FunctionName=function,
        Payload=json.dumps(payload).encode("utf8"),
        InvocationType="Event",
    )
