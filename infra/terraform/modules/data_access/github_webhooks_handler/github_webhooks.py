import hmac
from hashlib import sha1
import json
import os

import boto3
from botocore.exceptions import ClientError


'''
Environment variables required:
 - SNS_ARN, e.g. "arn:aws:sns:eu-west-1:1234"
 - STAGE, e.g. "dev", "alpha", etc...
 - GH_HOOK_SECRET, secret used in GitHub webhook
 =
'''


class SNSTopicNotFound(Exception):
    pass


def publish_to_sns(event, context):
    print("event received = {}".format(event))

    signature = event["headers"]["X-Hub-Signature"]
    message = event["body"]

    if not valid_signature(signature, message):
        return response(401, "Invalid signature")

    try:
        publish(
            topic=topic_arn(event["headers"]["X-GitHub-Event"]),
            message=message
        )
        return response(202, "Event published to SNS")
    except SNSTopicNotFound as error:
        return response(404, "SNS topic '{}' not found".format(error))


def topic_arn(event):
    """
    Returns the SNS Topic ARN for the event in the form of

    "{sns_arn}:{stage}_gh_{event}_events", for example:
    "arn:aws:sns:eu-west-1:1234:dev_github_team_events"
    """
    return "{sns_arn}:{stage}_github_{event}_events".format(
        sns_arn=os.environ["SNS_ARN"],
        stage=os.environ["STAGE"],
        event=event,
    )


def publish(topic, message):
    print("Publishing to '{}'. Message: '{}'".format(
        topic,
        message
    ))

    try:
        sns = boto3.client("sns")
        sns.publish(
            TopicArn=topic,
            Message=message
        )
    except ClientError as e:
        # Tried to publish to a non-existent SNS topic
        if e.response["Error"]["Code"] == "NotFound":
            raise SNSTopicNotFound(topic)


def response(status_code, message):
    print("Response {}: '{}'".format(status_code, message))

    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": message})
    }


# See GitHub documentation on webhooks' secret:
# https://developer.github.com/v3/repos/hooks/
def valid_signature(hmac_signature, message):
    sha_name, signature = hmac_signature.split("=")
    if sha_name == "sha1":
        mac = hmac.new(
            os.environ["GH_HOOK_SECRET"].encode("utf-8"),
            msg=message.encode("utf-8"),
            digestmod=sha1
        )
        if hmac.compare_digest(mac.hexdigest().encode("utf-8"), signature.encode("utf-8")):
            return True

    return False
