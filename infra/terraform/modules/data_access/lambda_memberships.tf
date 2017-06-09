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
            IAM_ARN_BASE = "arn:aws:iam::${var.account_id}"
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
        "arn:aws:iam::${var.account_id}:role/users/${var.env}_*"
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
