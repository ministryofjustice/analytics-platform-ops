import json
import os

import boto3


LAMBDA_ARNS = {
    "create_user_role": os.environ["CREATE_ROLE_ARN"],
    "delete_user_role": os.environ["DELETE_ROLE_ARN"],
}


def event_received(sns_event, context):
    print("SNS event received = {}".format(json.dumps(sns_event)))
    for record in sns_event["Records"]:
        event = json.loads(record["Sns"]["Message"])
        action = event["action"]
        if action == "member_added":
            member_added(event)
        elif action == "member_removed":
            member_removed(event)


def member_added(event):
    print("Handling 'member_added' event: {}".format(event))

    invoke_lambda(
        function=LAMBDA_ARNS["create_user_role"],
        payload=payload(event)
    )


def member_removed(event):
    print("Handling 'member_removed' event: {}".format(event))

    invoke_lambda(
        function=LAMBDA_ARNS["delete_user_role"],
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
