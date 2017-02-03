resource "aws_iam_group" "managers" {
    name = "analytics-managers"
}

resource "aws_iam_group" "analysts" {
    name = "analytics-analysts"
}

output "iam-managers-arn" {
    value = "${aws_iam_group.managers.arn}"
}

output "iam-analysts-arn" {
    value = "${aws_iam_group.analysts.arn}"
}

resource "aws_iam_group_policy" "managers-s3" {
    name = "analytics-managers"
    group = "${aws_iam_group.managers.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SourceBucketManagersReadWriteDelete",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:RestoreObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.moj-analytics-source.arn}"
    },
    {
      "Sid": "ScratchBucketManagersReadWriteDelete",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:RestoreObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.moj-analytics-scratch.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_group_policy" "analysts-s3" {
    name = "analytics-analysts"
    group = "${aws_iam_group.analysts.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SourceBucketAnalystsReadOnly",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.moj-analytics-source.arn}"
    },
    {
      "Sid": "ScratchBucketAnalystsReadWriteDelete",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:RestoreObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.moj-analytics-scratch.arn}"
    }
  ]
}
EOF
}

# resource "aws_iam_group_policy_attachment" "managers-s3" {
#     group = "${aws_iam_group.managers.name}"
#     policy_arn = "${aws_iam_policy.managers-s3.arn}"
# }

# resource "aws_iam_group_policy_attachment" "analysts-s3" {
#     group = "${aws_iam_group.analysts.name}"
#     policy_arn = "${aws_iam_policy.analysts-s3.arn}"
# }

resource "aws_iam_user" "shared-analyst" {
    name = "shared-analyst"
}

resource "aws_iam_access_key" "shared-analyst" {
    user = "${aws_iam_user.shared-analyst.name}"
}

resource "aws_iam_group_membership" "analysts" {
    name = "analyst-members"
    users = ["${aws_iam_user.shared-analyst.name}"]
    group = "${aws_iam_group.analysts.name}"
}



output "shared_analyst_access_key_id" {
  value = "${aws_iam_access_key.shared-analyst.id}"
}

output "shared_analyst_access_key_secret" {
  value = "${aws_iam_access_key.shared-analyst.secret}"
}
