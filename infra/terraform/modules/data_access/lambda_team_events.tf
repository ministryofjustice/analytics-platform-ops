# Zip the lambda function before the actual deploy
data "archive_file" "team_events_zip" {
    type        = "zip"
    source_dir  = "${path.module}/team_events"
    output_path = "/tmp/team_events.zip"
}

# Lambda function which handles GH team events
resource "aws_lambda_function" "team_events" {
    description = "Updates AWS resources in response to GH team events"
    filename = "/tmp/team_events.zip"
    source_code_hash = "${data.archive_file.team_events_zip.output_base64sha256}"
    function_name = "${var.env}_team_events"
    role = "${aws_iam_role.team_events_role.arn}"
    handler = "team_events.event_received"
    runtime = "python3.6"
    timeout = 10
    depends_on = ["data.archive_file.team_events_zip"]
    environment {
        variables = {
            LAMBDA_CREATE_TEAM_BUCKET_ARN = "${aws_lambda_function.create_team_bucket.arn}",
            LAMBDA_CREATE_TEAM_BUCKET_POLICIES_ARN = "${aws_lambda_function.create_team_bucket_policies.arn}",
            # TODO: Change with real ARNs. Fake for now
            LAMBDA_DELETE_TEAM_BUCKET_POLICIES_ARN = "TODO: fake ARN",
        }
    }
}

# Lambda function triggered by SNS notification
resource "aws_sns_topic_subscription" "team_events" {
    topic_arn = "${var.team_events_topic_arn}"
    protocol = "lambda"
    endpoint = "${aws_lambda_function.team_events.arn}"
}

# Permission to invoke the lambda function
resource "aws_lambda_permission" "allow_team_events_invocation" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.team_events.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${var.team_events_topic_arn}"
}

# Role running the lambda function
resource "aws_iam_role" "team_events_role" {
    name = "${var.env}_team_events_role"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'team_events_role' role
resource "aws_iam_role_policy" "team_events_role_policy" {
    name = "${var.env}_team_events_role_policy"
    role = "${aws_iam_role.team_events_role.id}"
# TODO: Add permission to invoke all lambda functions
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
        "${aws_lambda_function.create_team_bucket.arn}",
        "${aws_lambda_function.create_team_bucket_policies.arn}"
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
