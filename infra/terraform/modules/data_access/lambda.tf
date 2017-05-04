# Zip the lambda function before the actual deploy
data "archive_file" "gh_webhook_handler_zip" {
    type        = "zip"
    source_dir  = "${path.module}/gh_webhook_handler"
    output_path = "/tmp/gh_webhook_handler.zip"
}

# Lambda function which publishes GH events to SNS topics
resource "aws_lambda_function" "gh_webhook_handler" {
    description = "Publish GitHub events to the corresponding SNS topics"
    filename = "/tmp/gh_webhook_handler.zip"
    source_code_hash = "${data.archive_file.gh_webhook_handler_zip.output_base64sha256}"
    function_name = "${var.env}_gh_webhook_handler"
    role = "${aws_iam_role.gh_webhook_handler_role.arn}"
    handler = "index.handler"
    runtime = "python3.6"
    timeout = 10
    depends_on = ["data.archive_file.gh_webhook_handler_zip"]
    environment {
      variables = {
        STAGE = "${var.env}"
        SNS_ARN = "${var.sns_arn}"
        GH_HOOK_SECRET = "${var.gh_hook_secret}"
      }
    }
}

# Role assumed by the lambda function
resource "aws_iam_role" "gh_webhook_handler_role" {
    name = "${var.env}_gh_webhook_handler_role"
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

# Policies for the 'gh_webhook_handler_role' role
resource "aws_iam_role_policy" "gh_webhook_handler_role_policy" {
    name = "${var.env}_gh_webhook_handler_role_policy"
    role = "${aws_iam_role.gh_webhook_handler_role.id}"
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
        "${var.sns_arn}:${var.env}_gh_*_events"
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
