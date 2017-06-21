# Install dependencies
resource "null_resource" "teams_install_deps" {
    provisioner "local-exec" {
        command = "${path.module}/teams/build.sh"
    }

    triggers {
        requirements_sha = "${sha256(file("${path.module}/teams/requirements.txt"))}"
    }
}

# Zip the lambda function before the actual deploy
data "archive_file" "teams_zip" {
    type        = "zip"
    source_dir  = "${path.module}/teams"
    output_path = "/tmp/teams.zip"

    depends_on = ["null_resource.teams_install_deps"]
}

# Lambda function to create a team's S3 bucket
resource "aws_lambda_function" "create_team_bucket" {
    description = "Creates the team's S3 bucket"
    filename = "/tmp/teams.zip"
    source_code_hash = "${data.archive_file.teams_zip.output_base64sha256}"
    function_name = "${var.env}_create_team_bucket"
    role = "${aws_iam_role.create_team_bucket.arn}"
    handler = "teams.create_team_bucket"
    runtime = "python3.6"
    timeout = 10
    depends_on = ["data.archive_file.teams_zip"]
    environment {
        variables = {
            BUCKET_REGION = "${var.region}",
            STAGE = "${var.env}",
            SENTRY_DSN = "${var.sentry_dsn}",
        }
    }
}

# Role assumed by the 'create_team_bucket' lambda function
resource "aws_iam_role" "create_team_bucket" {
    name = "${var.env}_create_team_bucket"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'create_team_bucket' role
resource "aws_iam_role_policy" "create_team_bucket" {
    name = "${var.env}_create_team_bucket"
    role = "${aws_iam_role.create_team_bucket.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanCreateBuckets",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${var.env}-*"
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

# Lambda function to create policies for a team S3 bucket
resource "aws_lambda_function" "create_team_bucket_policies" {
    description = "Creates policies for the team S3 bucket"
    filename = "/tmp/teams.zip"
    source_code_hash = "${data.archive_file.teams_zip.output_base64sha256}"
    function_name = "${var.env}_create_team_bucket_policies"
    role = "${aws_iam_role.create_team_bucket_policies.arn}"
    handler = "teams.create_team_bucket_policies"
    runtime = "python3.6"
    timeout = 10
    depends_on = ["data.archive_file.teams_zip"]
    environment {
        variables = {
            STAGE = "${var.env}",
            SENTRY_DSN = "${var.sentry_dsn}",
        }
    }
}

# Role assumed by the 'create_team_bucket_policies' lambda function
resource "aws_iam_role" "create_team_bucket_policies" {
    name = "${var.env}_create_team_bucket_policies"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'create_team_bucket_policies' role
resource "aws_iam_role_policy" "create_team_bucket_policies" {
    name = "${var.env}_create_team_bucket_policies"
    role = "${aws_iam_role.create_team_bucket_policies.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanCreateIAMPolicies",
      "Effect": "Allow",
      "Action": [
        "iam:CreatePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:policy/${var.env}-*"
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

# Lambda function to delete policies for a team S3 bucket
resource "aws_lambda_function" "delete_team_bucket_policies" {
    description = "Delete the policies for the team S3 bucket"
    filename = "/tmp/teams.zip"
    source_code_hash = "${data.archive_file.teams_zip.output_base64sha256}"
    function_name = "${var.env}_delete_team_bucket_policies"
    role = "${aws_iam_role.delete_team_bucket_policies.arn}"
    handler = "teams.delete_team_bucket_policies"
    runtime = "python3.6"
    timeout = 300
    depends_on = ["data.archive_file.teams_zip"]
    environment {
        variables = {
            STAGE = "${var.env}",
            IAM_ARN_BASE = "arn:aws:iam::${var.account_id}",
            SENTRY_DSN = "${var.sentry_dsn}",
        }
    }
}

# Role assumed by the 'delete_team_bucket_policies' lambda function
resource "aws_iam_role" "delete_team_bucket_policies" {
    name = "${var.env}_delete_team_bucket_policies"
    assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'delete_team_bucket_policies' role
resource "aws_iam_role_policy" "delete_team_bucket_policies" {
    name = "${var.env}_delete_team_bucket_policies"
    role = "${aws_iam_role.delete_team_bucket_policies.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanDeleteIAMPolicies",
      "Effect": "Allow",
      "Action": [
        "iam:DeletePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:policy/${var.env}-*"
      ]
    },
    {
      "Sid": "CanDetachPolicies",
      "Effect": "Allow",
      "Action": [
        "iam:ListEntitiesForPolicy",
        "iam:DetachGroupPolicy",
        "iam:DetachRolePolicy",
        "iam:DetachUserPolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:*"
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
