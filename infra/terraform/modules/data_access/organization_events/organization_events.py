import json
import os

import boto3


def event_received(sns_event, context):
    EVENT_HANDLERS = {
        "member_added": os.environ["CREATE_ROLE_ARN"],
        "member_removed": os.environ["DELETE_ROLE_ARN"],
    }

    print("SNS event received = {}".format(json.dumps(sns_event)))
    for record in sns_event["Records"]:
        event = json.loads(record["Sns"]["Message"])
        action = event["action"]

        if action in EVENT_HANDLERS:
            invoke_lambda(
                function=EVENT_HANDLERS[action],
                payload=payload(event)
            )


def invoke_lambda(function, payload):
    client = boto3.client("lambda")
    client.invoke(
        FunctionName=function,
        Payload=bytes(json.dumps(payload), "utf8"),
        InvocationType="Event",
    )


def payload(event):
    return {
        "username": event["membership"]["user"]["login"],
    }
