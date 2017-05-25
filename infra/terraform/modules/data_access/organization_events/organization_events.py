'''
Environment variables:
 - LAMBDA_CREATE_ROLE_ARN, ARN of the lambda function to create the IAM role
 - LAMBDA_DELETE_ROLE_ARN, ARN of the lambda function to delete the IAM role
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
    EVENT_HANDLERS = {
        "member_added": os.environ["LAMBDA_CREATE_ROLE_ARN"],
        "member_removed": os.environ["LAMBDA_DELETE_ROLE_ARN"],
    }

    LOG.debug("SNS event received = {}".format(json.dumps(sns_event)))
    for record in sns_event["Records"]:
        event = json.loads(record["Sns"]["Message"])
        action = event["action"]

        if action in EVENT_HANDLERS:
            invoke_lambda(
                function=EVENT_HANDLERS[action],
                payload={"username": event["membership"]["user"]["login"]}
            )


def invoke_lambda(function, payload):
    client = boto3.client("lambda")
    client.invoke(
        FunctionName=function,
        Payload=json.dumps(payload).encode("utf8"),
        InvocationType="Event",
    )
