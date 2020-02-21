resource "aws_iam_role" "buckets_archiver" {
  name        = "${var.env}_buckets_archiver"
  description = "IAM role assumed by the buckets archiver"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.k8s_worker_role_arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "buckets_archiver" {
  role       = "${aws_iam_role.buckets_archiver.name}"
  policy_arn = "${aws_iam_policy.buckets_archiver.arn}"
}

resource "aws_iam_policy" "buckets_archiver" {
  name = "${var.env}_buckets_archiver"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanListBuckets",
      "Effect": "Allow",
      "Action": [
          "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${var.env}-*"
      ]
    },
    {
      "Sid": "CanReadAndDeleteFromSource",
      "Effect": "Allow",
      "Action": [
          "s3:GetObject",
          "s3:DeleteObject",
      ],
      "Resource": [
        "arn:aws:s3:::${var.env}-*/*"
      ]
    },
    {
      "Sid": "CanWriteToDestination",
      "Effect": "Allow",
      "Action": [
          "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.archived_buckets_data.arn}/*"
      ]
    },
    {
      "Sid": "CanDeleteBuckets",
      "Effect": "Allow",
      "Action": [
          "s3:DeleteBucket"
      ],
      "Resource": [
          "arn:aws:s3:::${var.env}-*"
      ]
    }
  ]
}
EOF
}
