# Zip the lambda function before the actual deploy
data "archive_file" "organization_events_zip" {
    type        = "zip"
    source_dir  = "${path.module}/organization_events"
    output_path = "/tmp/organization_events.zip"
}

# Lambda function which handles GH organization events
resource "aws_lambda_function" "organization_events" {
    description = "Updates IAM resources in response to GH organization events"
    filename = "/tmp/organization_events.zip"
    source_code_hash = "${data.archive_file.organization_events_zip.output_base64sha256}"
    function_name = "${var.env}_organization_events"
    role = "${aws_iam_role.organization_events_role.arn}"
    handler = "organization_events.event_received"
    runtime = "python3.6"
    timeout = 10
    depends_on = ["data.archive_file.organization_events_zip"]
    environment {
        variables = {
            CREATE_ROLE_ARN = "${aws_lambda_function.create_user_role.arn}",
            DELETE_ROLE_ARN = "${aws_lambda_function.delete_user_role.arn}",
        }
    }
}

# Lambda function triggered by SNS notification
resource "aws_sns_topic_subscription" "organization_events" {
    topic_arn = "${var.organization_events_topic_arn}"
    protocol = "lambda"
    endpoint = "${aws_lambda_function.organization_events.arn}"
}

# Permission to invoke the lambda function
resource "aws_lambda_permission" "allow_organization_events_invocation" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.organization_events.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${var.organization_events_topic_arn}"
}

# Role running the lambda function
resource "aws_iam_role" "organization_events_role" {
    name = "${var.env}_organization_events_role"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'organization_events_role' role
resource "aws_iam_role_policy" "organization_events_role_policy" {
    name = "${var.env}_organization_events_role_policy"
    role = "${aws_iam_role.organization_events_role.id}"
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
        "${aws_lambda_function.create_user_role.arn}",
        "${aws_lambda_function.delete_user_role.arn}"
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
