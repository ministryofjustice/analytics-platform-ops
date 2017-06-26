# Install dependencies
resource "null_resource" "users_install_deps" {
    provisioner "local-exec" {
        command = "${path.module}/users/build.sh"
    }

    triggers {
        build_sh_sha = "${sha256(file("${path.module}/users/build.sh"))}"
        requirements_sha = "${sha256(file("${path.module}/users/requirements.txt"))}"
    }
}

# Zip the lambda function before the actual deploy
data "archive_file" "users_zip" {
    type        = "zip"
    source_dir  = "${path.module}/users"
    output_path = "/tmp/users.zip"
}

# Lambda function adds an IAM role given its username
resource "aws_lambda_function" "create_user_role" {
    description = "Adds an IAM role for the given user"
    filename = "/tmp/users.zip"
    source_code_hash = "${data.archive_file.users_zip.output_base64sha256}"
    function_name = "${var.env}_create_user_role"
    role = "${aws_iam_role.create_user_role.arn}"
    handler = "users.create_user_role"
    runtime = "python3.6"
    timeout = 10
    depends_on = ["data.archive_file.users_zip"]
    environment {
        variables = {
            ENV = "${var.env}",
            SAML_PROVIDER_ARN = "${var.saml_provider_arn}",
            K8S_WORKER_ROLE_ARN = "${var.k8s_worker_role_arn}",
            SENTRY_DSN = "${var.sentry_dsn}",
        }
    }
}

# Role assumed by the 'create_user_role' lambda function
resource "aws_iam_role" "create_user_role" {
    name = "${var.env}_create_user_role"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'create_user_role' role
resource "aws_iam_role_policy" "create_user_role_policy" {
    name = "${var.env}_create_user_role_policy"
    role = "${aws_iam_role.create_user_role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanCreateRoles",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole"
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

# Lambda function delete an IAM role given its username
resource "aws_lambda_function" "delete_user_role" {
    description = "Delete the IAM role for the given user"
    filename = "/tmp/users.zip"
    source_code_hash = "${data.archive_file.users_zip.output_base64sha256}"
    function_name = "${var.env}_delete_user_role"
    role = "${aws_iam_role.delete_user_role.arn}"
    handler = "users.delete_user_role"
    runtime = "python3.6"
    timeout = 10
    depends_on = ["data.archive_file.users_zip"]
    environment {
        variables = {
            ENV = "${var.env}",
            SENTRY_DSN = "${var.sentry_dsn}",
        }
    }
}

# Role assumed by the 'delete_user_role' lambda function
resource "aws_iam_role" "delete_user_role" {
    name = "${var.env}_delete_user_role"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'delete_user_role' role
resource "aws_iam_role_policy" "delete_user_role_policy" {
    name = "${var.env}_delete_user_role_policy"
    role = "${aws_iam_role.delete_user_role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanDeleteRoles",
      "Effect": "Allow",
      "Action": [
        "iam:DeleteRole",
        "iam:ListAttachedRolePolicies",
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
