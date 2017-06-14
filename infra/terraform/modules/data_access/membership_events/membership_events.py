'''
Environment variables:
 - LAMBDA_ATTACH_BUCKET_POLICY_ARN, ARN of the lambda function to attach the
   IAM policy for the bucket to the IAM role
 - LAMBDA_DETACH_BUCKET_POLICY_ARN, ARN of the lambda function to detach the
   IAM policy for the bucket to the IAM role
 - LOG_LEVEL, change the logging level (default is "DEBUG"). Must be one of
   the python logging supported levels: "CRITICAL", "ERROR", "WARNING",
   "INFO" or "DEBUG"
   (See: https://docs.python.org/2/library/logging.html#logging-levels)
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
    EVENT_HANDLERS = {
        "added": os.environ["LAMBDA_ATTACH_BUCKET_POLICY_ARN"],
        "removed": os.environ["LAMBDA_DETACH_BUCKET_POLICIES_ARN"],
    }

    LOG.debug("SNS event received = {}".format(json.dumps(sns_event)))
    for record in sns_event["Records"]:
        event = json.loads(record["Sns"]["Message"])
        action = event["action"]

        if event["scope"] != "team":
            continue

        if action in EVENT_HANDLERS:
            invoke_lambda(
                function=EVENT_HANDLERS[action],
                payload=payload(event),
            )


def invoke_lambda(function, payload):
    client = boto3.client("lambda")
    client.invoke(
        FunctionName=function,
        Payload=json.dumps(payload).encode("utf8"),
        InvocationType="Event",
    )


def payload(event):
    result = {
        "user": {"username": event["member"]["login"]},
        "team": {"slug": event["team"]["slug"]},
    }
    if event["action"] == "added":
        result["policy"] = {"type": POLICY_READ_WRITE}

    return result
