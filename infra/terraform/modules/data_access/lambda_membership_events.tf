# Zip the lambda function before the actual deploy
data "archive_file" "membership_events_zip" {
    type        = "zip"
    source_dir  = "${path.module}/membership_events"
    output_path = "/tmp/membership_events.zip"
}

# Lambda function which handles GH membership events
resource "aws_lambda_function" "membership_events" {
    description = "Updates IAM resources in response to GH membership events"
    filename = "/tmp/membership_events.zip"
    source_code_hash = "${data.archive_file.membership_events_zip.output_base64sha256}"
    function_name = "${var.env}_membership_events"
    role = "${aws_iam_role.membership_events_role.arn}"
    handler = "membership_events.event_received"
    runtime = "python3.6"
    timeout = 10
    depends_on = ["data.archive_file.membership_events_zip"]
    environment {
        variables = {
            LAMBDA_ATTACH_BUCKET_POLICY_ARN = "${aws_lambda_function.attach_bucket_policy.arn}",
            # TODO: Replace with actual lambda function ARN
            LAMBDA_DETACH_BUCKET_POLICY_ARN = "TODO: detach_bucket_policy.arn",
            # LAMBDA_DETACH_BUCKET_POLICY_ARN = "${aws_lambda_function.detach_bucket_policy.arn}",
        }
    }
}

# Lambda function triggered by SNS notification
resource "aws_sns_topic_subscription" "membership_events" {
    topic_arn = "${var.membership_events_topic_arn}"
    protocol = "lambda"
    endpoint = "${aws_lambda_function.membership_events.arn}"
}

# Permission to invoke the lambda function
resource "aws_lambda_permission" "allow_membership_events_invocation" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.membership_events.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${var.membership_events_topic_arn}"
}

# Role running the lambda function
resource "aws_iam_role" "membership_events_role" {
    name = "${var.env}_membership_events_role"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'membership_events_role' role
resource "aws_iam_role_policy" "membership_events_role_policy" {
    name = "${var.env}_membership_events_role_policy"
    role = "${aws_iam_role.membership_events_role.id}"
# TODO: Add 'aws_lambda_function.detach_bucket_policy.arn'
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanInvokeLambdaFunctions",
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "${aws_lambda_function.attach_bucket_policy.arn}"
      ]
    },
    {
      "Sid": "CanLog",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}
