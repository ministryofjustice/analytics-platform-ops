data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals = {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Role assumed by the 'ship_s3_logs_to_elasticsearch' lambda function
resource "aws_iam_role" "s3_logs_to_elasticsearch" {
  name               = "s3_logs_to_elasticsearch"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'ship_s3_logs_to_elasticsearch' role
resource "aws_iam_role_policy" "s3_logs_to_elasticsearch" {
  name = "s3_logs_to_elasticsearch"
  role = "${aws_iam_role.s3_logs_to_elasticsearch.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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
    },
    {
      "Sid": "Stmt1499439833532",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.s3_logs.arn}"
    },
    {
      "Sid": "Stmt1499439848123",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.s3_logs.arn}/*"
    }
  ]
}
EOF
}

# Role assumed by the 'ship_cloudtrail_to_elasticsearch' lambda function
resource "aws_iam_role" "cloudtrail_to_elasticsearch" {
  name               = "cloudtrail_to_elasticsearch"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

# Policies for the 'ship_cloudtrail_to_elasticsearch' role
resource "aws_iam_role_policy" "cloudtrail_to_elasticsearch" {
  name = "cloudtrail_to_elasticsearch"
  role = "${aws_iam_role.cloudtrail_to_elasticsearch.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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
    },
    {
      "Sid": "Stmt1499439833532",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${var.cloudtrail_s3_bucket_arn}"
    },
    {
      "Sid": "Stmt1499439848123",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "${var.cloudtrail_s3_bucket_arn}/*"
    }
  ]
}
EOF
}

# VPC flow logs

data "aws_iam_policy_document" "vpcflowlogs_assume_role_policy_document" {
  "statement" {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [
        "vpc-flow-logs.amazonaws.com",
        "delivery.logs.amazonaws.com",
        "lambda.amazonaws.com",
      ]

      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "vpcflowlogs_policy_document" {
  "statement" {
    sid    = "CanLog"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy",
      "s3:PutBucketPolicy",
    ]

    resources = ["${aws_s3_bucket.vpcflowlogs_bucket.arn}"]
  }

  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "logs:CreateLogDelivery",
      "logs:DeleteLogDelivery",
    ]

    resources = ["${aws_s3_bucket.vpcflowlogs_bucket.arn}/*"]
  }
}

resource "aws_iam_role" "vpcflowlogs_to_elasticsearch_role" {
  name               = "vpcflowlogs_to_elasticsearch"
  assume_role_policy = "${data.aws_iam_policy_document.vpcflowlogs_assume_role_policy_document.json}"
}

resource "aws_iam_policy" "vpcflowlogs_to_elasticsearch_policy" {
  policy = "${data.aws_iam_policy_document.vpcflowlogs_policy_document.json}"
  name   = "vpcflowlogs_to_elasticsearch"
}

resource "aws_iam_role_policy_attachment" "vpcflowlogs_to_elasticsearch_policy_attachment" {
  policy_arn = "${aws_iam_policy.vpcflowlogs_to_elasticsearch_policy.arn}"
  role       = "${aws_iam_role.vpcflowlogs_to_elasticsearch_role.name}"
}
