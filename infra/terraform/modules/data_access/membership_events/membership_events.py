'''
Environment variables:
 - LAMBDA_ATTACH_BUCKET_POLICY_ARN, ARN of the lambda function to attach the
   IAM policy for the bucket to the IAM role
 - LAMBDA_DETACH_BUCKET_POLICY_ARN, ARN of the lambda function to detach the
   IAM policy for the bucket to the IAM role
 - LOG_LEVEL, change the logging level (default is "DEBUG"). Must be one of
   the python logging supported levels: "CRITICAL", "ERROR", "WARNING",
   "INFO" or "DEBUG" (See: https://docs.python.org/2/library/logging.html#logging-levels)
'''

import json
import logging
import os

import boto3


POLICY_READ_WRITE = "readwrite"


LOG = logging.getLogger(__name__)
LOG_LEVEL = os.environ.get("LOG_LEVEL", "DEBUG")
LOG.setLevel(LOG_LEVEL)


# "membership" webhook event: https://developer.github.com/v3/activity/events/types/#membershipevent
def event_received(sns_event, context):
    LOG.debug("SNS event received = {}".format(json.dumps(sns_event)))
    for record in sns_event["Records"]:
        event = json.loads(record["Sns"]["Message"])
        action = event["action"]

        if event["scope"] != "team":
            continue

        if action == "added":
            invoke_lambda(
                function=os.environ["LAMBDA_ATTACH_BUCKET_POLICY_ARN"],
                payload=attach_payload(event),
            )
        elif action == "removed":
            invoke_lambda(
                function=os.environ["LAMBDA_DETACH_BUCKET_POLICIES_ARN"],
                payload=detach_payload(event),
            )


def invoke_lambda(function, payload):
    client = boto3.client("lambda")
    client.invoke(
        FunctionName=function,
        Payload=json.dumps(payload).encode("utf8"),
        InvocationType="Event",
    )


def attach_payload(event):
    return {
        "user": {"username": event["member"]["login"]},
        "team": {"slug": event["team"]["slug"]},
        "policy": {"type": POLICY_READ_WRITE},
    }


def detach_payload(event):
    return {
        "user": {"username": event["member"]["login"]},
        "team": {"slug": event["team"]["slug"]},
    }
