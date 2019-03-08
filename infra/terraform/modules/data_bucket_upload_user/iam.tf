resource "aws_iam_user" "system" {
  name = "${var.system_name}_uploader"
  path = "/uploaders/"
}

resource "aws_iam_access_key" "system_user" {
  user = "${aws_iam_user.system.name}"
}

data "aws_iam_policy_document" "system_user_s3_upload_readwrite" {
  statement {
    sid = "ListUploadBucket"

    actions = [
      "s3:ListBucket",
    ]

    effect = "Allow"

    resources = [
      "${var.upload_bucket_arn}",
      "${var.upload_bucket_arn}/*",
    ]
  }

  statement {
    sid = "ReadWriteUploadBucket"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersion",
      "s3:RestoreObject",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:CreateBucket",
    ]

    effect = "Allow"

    resources = [
      "${var.upload_bucket_arn}",
      "${var.upload_bucket_arn}/*",
    ]
  }

  statement {
    actions = [
      "athena:*",
      "glue:*",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "cloudwatch:PutMetricData",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:/aws-glue/*",
    ]
  }
}

resource "aws_iam_policy" "system_user_s3_readwrite" {
  name   = "${var.system_name}_s3_upload_readwrite"
  path   = "/uploaders/${var.system_name}/"
  policy = "${data.aws_iam_policy_document.system_user_s3_upload_readwrite.json}"
}

resource "aws_iam_user_policy_attachment" "system_user_s3_upload" {
  user       = "${aws_iam_user.system.name}"
  policy_arn = "${aws_iam_policy.system_user_s3_readwrite.arn}"
}

resource "aws_iam_role" "lookups_job_role" {
  name = "lookups_job_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["glue.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": "Assumejob"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lookups_job_role_attatchment" {
  policy_arn = "${aws_iam_policy.system_user_s3_readwrite.arn}"
  role       = "${aws_iam_role.lookups_job_role.name}"
}

data "aws_iam_policy_document" "system_policy_s3_readonly" {
  statement {
    sid = "ListUploadBucketRO"

    actions = [
      "s3:ListBucket",
    ]

    effect = "Allow"

    resources = [
      "${var.upload_bucket_arn}",
    ]
  }

  statement {
    sid = "ReadOnlyBucketRo"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
    ]

    effect = "Allow"

    resources = [
      "${var.upload_bucket_arn}",
      "${var.upload_bucket_arn}/*",
    ]
  }

  statement {
    actions = [
      "athena:*",
      "glue:*",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "cloudwatch:PutMetricData",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:/aws-glue/*",
    ]
  }
}

resource "aws_iam_policy" "system_user_s3_readonly" {
  name   = "${var.system_name}_s3_readonly"
  path   = "/uploaders/${var.system_name}/"
  policy = "${data.aws_iam_policy_document.system_policy_s3_readonly.json}"
}

resource "aws_iam_role" "lookups_user_role" {
  name = "lookups_user_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["glue.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": "AssumeUser"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lookups_user_role_attatchment" {
  policy_arn = "${aws_iam_policy.system_user_s3_readonly.arn}"
  role       = "${aws_iam_role.lookups_user_role.name}"
}
