# Install dependencies
resource "null_resource" "memberships_install_deps" {
    provisioner "local-exec" {
        command = "${path.module}/memberships/build.sh"
    }

    triggers {
        build_sh_sha = "${sha256(file("${path.module}/memberships/build.sh"))}"
        requirements_sha = "${sha256(file("${path.module}/memberships/requirements.txt"))}"
    }
}

# Zip the lambda function before the actual deploy
data "archive_file" "memberships_zip" {
    type        = "zip"
    source_dir  = "${path.module}/memberships"
    output_path = "/tmp/memberships.zip"
}

# Lambda function to attach bucket IAM policy to IAM role
resource "aws_lambda_function" "attach_bucket_policy" {
    description = "Attaches bucket IAM policy to IAM role"
    filename = "/tmp/memberships.zip"
    source_code_hash = "${data.archive_file.memberships_zip.output_base64sha256}"
    function_name = "${var.env}_attach_bucket_policy"
    role = "${aws_iam_role.attach_bucket_policy.arn}"
    handler = "memberships.attach_bucket_policy"
    runtime = "python3.6"
    timeout = 10
    depends_on = ["data.archive_file.memberships_zip"]
    environment {
        variables = {
            STAGE = "${var.env}",
            IAM_ARN_BASE = "arn:aws:iam::${var.account_id}",
            SENTRY_DSN = "${var.sentry_dsn}",
        }
    }
}

# Role assumed by the 'attach_bucket_policy' lambda function
resource "aws_iam_role" "attach_bucket_policy" {
    name = "${var.env}_attach_bucket_policy"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'attach_bucket_policy' role
resource "aws_iam_role_policy" "attach_bucket_policy" {
    name = "${var.env}_attach_bucket_policy"
    role = "${aws_iam_role.attach_bucket_policy.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanAttachPolicy",
      "Effect": "Allow",
      "Action": [
        "iam:AttachRolePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:role/${var.env}_user_*"
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

# Lambda function to detach bucket IAM policy from an IAM role
resource "aws_lambda_function" "detach_bucket_policies" {
    description = "Detaches bucket IAM policy from an IAM role"
    filename = "/tmp/memberships.zip"
    source_code_hash = "${data.archive_file.memberships_zip.output_base64sha256}"
    function_name = "${var.env}_detach_bucket_policies"
    role = "${aws_iam_role.detach_bucket_policies.arn}"
    handler = "memberships.detach_bucket_policies"
    runtime = "python3.6"
    timeout = 10
    depends_on = ["data.archive_file.memberships_zip"]
    environment {
        variables = {
            STAGE = "${var.env}",
            IAM_ARN_BASE = "arn:aws:iam::${var.account_id}",
            SENTRY_DSN = "${var.sentry_dsn}",
        }
    }
}

# Role assumed by the 'detach_bucket_policies' lambda function
resource "aws_iam_role" "detach_bucket_policies" {
    name = "${var.env}_detach_bucket_policies"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'detach_bucket_policies' role
resource "aws_iam_role_policy" "detach_bucket_policies" {
    name = "${var.env}_detach_bucket_policies"
    role = "${aws_iam_role.detach_bucket_policies.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanDetachPolicy",
      "Effect": "Allow",
      "Action": [
        "iam:DetachRolePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:role/${var.env}_user_*"
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
