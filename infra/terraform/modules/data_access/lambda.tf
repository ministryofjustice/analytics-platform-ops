# Zip the lambda function before the actual deploy
data "archive_file" "github_webhooks_handler_zip" {
    type        = "zip"
    source_dir  = "${path.module}/github_webhooks_handler"
    output_path = "/tmp/github_webhooks_handler.zip"
}

# Lambda function which publishes GH events to SNS topics
resource "aws_lambda_function" "github_webhooks_handler" {
    description = "Publish GitHub events to the corresponding SNS topics"
    filename = "/tmp/github_webhooks_handler.zip"
    source_code_hash = "${data.archive_file.github_webhooks_handler_zip.output_base64sha256}"
    function_name = "${var.env}_github_webhooks_handler"
    role = "${aws_iam_role.github_webhooks_handler_role.arn}"
    handler = "github_webhooks.publish_to_sns"
    runtime = "python3.6"
    timeout = 10
    depends_on = ["data.archive_file.github_webhooks_handler_zip"]
    environment {
      variables = {
        STAGE = "${var.env}"
        SNS_ARN = "${var.sns_arn}"
        GH_HOOK_SECRET = "${var.gh_hook_secret}"
      }
    }
}

# Role assumed by the lambda function
resource "aws_iam_role" "github_webhooks_handler_role" {
    name = "${var.env}_github_webhooks_handler_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Policies for the 'github_webhooks_handler_role' role
resource "aws_iam_role_policy" "github_webhooks_handler_role_policy" {
    name = "${var.env}_github_webhooks_handler_role_policy"
    role = "${aws_iam_role.github_webhooks_handler_role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanPublish",
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": [
        "${var.sns_arn}:${var.env}_github_*_events"
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
