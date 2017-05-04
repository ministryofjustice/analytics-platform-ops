import hmac
from hashlib import sha1
import json
import os

import boto3
from botocore.exceptions import ClientError


SNS_ARN = os.environ.get("SNS_ARN")
STAGE = os.environ.get("STAGE")
GH_HOOK_SECRET = os.environ.get("GH_HOOK_SECRET")

sns = boto3.client("sns")


class SNSTopicNotFoundError(Exception):
    """Raised when trying to publish to a non-existent SNS topic"""
    pass


# e.g. "arn:aws:sns:eu-west-1:1234:dev_gh_team_events"
def _topic_arn(gh_event):
    return "{}:{}_gh_{}_events".format(
        SNS_ARN,
        STAGE,
        gh_event,
    )


def _publish(topic_arn, message):
    print("Publishing to '{}'. Message: '{}'".format(
        topic_arn,
        message
    ))

    try:
        sns.publish(
            TopicArn=topic_arn,
            Message=message
        )
    except ClientError as e:
        if e.response["Error"]["Code"] == "NotFound":
            err = "SNS topic '{}' not found".format(topic_arn)
            raise SNSTopicNotFoundError(err)


def _response(status_code, message):
    print("Response {}: '{}'".format(status_code, message))

    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": message})
    }


# See article on handling GH Webhooks in Python:
# https://simpleisbetterthancomplex.com/tutorial/2016/10/31/how-to-handle-github-webhooks-using-django.html
def _valid_signature(hmac_signature, message):
    sha_name, signature = hmac_signature.split('=')
    if sha_name != "sha1":
        return False

    mac = hmac.new(
        GH_HOOK_SECRET.encode(),
        msg=message.encode(),
        digestmod=sha1
    )
    if hmac.compare_digest(mac.hexdigest().encode(), signature.encode()):
        return True

    return False


def handler(event, context):
    print("event received = {}".format(event))

    topic = event["headers"]["X-GitHub-Event"]
    topic_arn = _topic_arn(topic)
    signature = event["headers"]["X-Hub-Signature"]
    message = event["body"]

    if not _valid_signature(signature, message):
        return _response(401, "Invalid signature")

    try:
        _publish(topic_arn, message)
        return _response(201, "event published to SNS")
    except SNSTopicNotFoundError as e:
        return _response(404, str(e))
