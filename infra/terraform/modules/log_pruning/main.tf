# Install dependencies
resource "null_resource" "prune_logs_deps" {
    provisioner "local-exec" {
        command = "${path.module}/prune_logs/build.sh"
    }
    triggers {
        force_rebuild = "${timestamp()}"
    }
}

# Zip the lambda function before the actual deploy
data "archive_file" "prune_logs_zip" {
    type        = "zip"
    source_dir  = "${path.module}/prune_logs"
    output_path = "/tmp/prune_logs.zip"
    depends_on = ["null_resource.prune_logs_deps"]
}

# Lambda function which invokes curator to prune logs
resource "aws_lambda_function" "prune_logs" {
    description = "Prune elasticsearch log indexes"
    filename = "/tmp/prune_logs.zip"
    source_code_hash = "${data.archive_file.prune_logs_zip.output_base64sha256}"
    function_name = "${var.env}_prune_logs"
    role = "${aws_iam_role.prune_logs_role.arn}"
    handler = "lambda.handler"
    runtime = "python3.6"
    timeout = 300
    depends_on = ["data.archive_file.prune_logs_zip"]
    environment {
        variables = {
            ENV = "${var.env}"
        }
    }
}

# Role running the lambda function
resource "aws_iam_role" "prune_logs_role" {
    name = "${var.env}_prune_logs_role"
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

# Cloudwatch event rule for triggering the lambda function
resource "aws_cloudwatch_event_rule" "nightly" {
  name        = "nightly"
  description = "Trigger every night at 2am"
  schedule_expression = "cron(0 2 * * ? *)"
}

resource "aws_cloudwatch_event_target" "prune_logs" {
  rule      = "${aws_cloudwatch_event_rule.nightly.name}"
  target_id = "prune-logs"
  arn       = "${aws_lambda_function.prune_logs.arn}"
}

resource "aws_sns_topic" "aws_logins" {
  name = "aws-console-logins"
}
