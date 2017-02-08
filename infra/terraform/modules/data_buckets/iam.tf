resource "aws_iam_group" "managers" {
    name = "analytics-managers"
}

resource "aws_iam_group" "analysts" {
    name = "analytics-analysts"
}

resource "aws_iam_group_policy" "managers_s3" {
    name = "analytics-managers"
    group = "${aws_iam_group.managers.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SourceBucketManagersListBucket",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.source.arn}"
    },
    {
      "Sid": "SourceBucketManagersReadWriteDeleteObjects",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject",
        "s3:RestoreObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.source.arn}/*"
    },
    {
      "Sid": "ScratchBucketManagersListBucket",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.scratch.arn}"
    },
    {
      "Sid": "ScratchBucketManagersReadWriteDeleteObjects",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject",
        "s3:RestoreObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.scratch.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_group_policy" "analysts_s3" {
    name = "analytics-analysts"
    group = "${aws_iam_group.analysts.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SourceBucketAnalystsListBucket",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.source.arn}"
    },
    {
      "Sid": "SourceBucketAnalystsReadOnly",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.source.arn}/*"
    },
    {
      "Sid": "ScratchBucketAnalystsListBucket",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.scratch.arn}"
    },
    {
      "Sid": "ScratchBucketAnalystsReadWriteDeleteObjects",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject",
        "s3:RestoreObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.scratch.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_user" "shared_analyst" {
    name = "shared-analyst"
}

resource "aws_iam_access_key" "shared_analyst" {
    user = "${aws_iam_user.shared_analyst.name}"
}

resource "aws_iam_group_membership" "analysts" {
    name = "analyst_members"
    users = ["${aws_iam_user.shared_analyst.name}"]
    group = "${aws_iam_group.analysts.name}"
}
