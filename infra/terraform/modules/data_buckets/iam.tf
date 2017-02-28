# - The s3:GetBucketLocation and s3:ListAllMyBuckets actions are necessary
#   to allow the user to see the buckets in the AWS console
# - The s3:ListBucket action is necessary to allow users to list objects
#   in a bucket
#
# See: https://aws.amazon.com/blogs/security/writing-iam-policies-how-to-grant-access-to-an-amazon-s3-bucket/

resource "aws_iam_group" "managers" {
    name = "${var.env}-managers"
}

resource "aws_iam_group" "analysts" {
    name = "${var.env}-analysts"
}

resource "aws_iam_group_policy" "managers_s3" {
    name = "${var.env}-managers"
    group = "${aws_iam_group.managers.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ManagersListAllBucketsInConsole",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Sid": "ManagersListBucketObjects",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.source.arn}",
        "${aws_s3_bucket.scratch.arn}"
      ]
    },
    {
      "Sid": "ManagersReadWriteDeleteObjects",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:RestoreObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.source.arn}/*",
        "${aws_s3_bucket.scratch.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_group_policy" "analysts_s3" {
    name = "${var.env}-analysts"
    group = "${aws_iam_group.analysts.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AnalystsListAllBucketsInConsole",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Sid": "AnalystsListBucketObjects",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.source.arn}",
        "${aws_s3_bucket.scratch.arn}"
      ]
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
      "Sid": "ScratchBucketAnalystsReadWriteDeleteObjects",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
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
    name = "${var.env}-shared-analyst"
}

resource "aws_iam_access_key" "shared_analyst" {
    user = "${aws_iam_user.shared_analyst.name}"
}

resource "aws_iam_group_membership" "analysts" {
    name = "${var.env}-analyst-members"
    users = ["${aws_iam_user.shared_analyst.name}"]
    group = "${aws_iam_group.analysts.name}"
}
