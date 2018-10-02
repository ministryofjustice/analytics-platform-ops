# The '{ENV}-moj-analytics-crest' bucket contains sensitive information.
#
# Only users in the '${ENV}-crest-manager' can read/write in it

# S3 Bucket
resource "aws_s3_bucket" "crest" {
  bucket = "${var.env}-moj-analytics-crest"
  acl    = "private"

  tags {
    Name = "${var.env}-moj-analytics-crest"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# IAM Group
resource "aws_iam_group" "crest_managers" {
  name = "${var.env}-crest-managers"
}

# IAM Group Policy
resource "aws_iam_group_policy" "crest_managers_s3" {
  name  = "${var.env}-crest-managers"
  group = "${aws_iam_group.crest_managers.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CRESTManagersListAllBucketsInConsole",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Sid": "CRESTManagersListBucketObjects",
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.crest.arn}"
      ]
    },
    {
      "Sid": "CRESTManagersReadWriteDeleteObjects",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:RestoreObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.crest.arn}/*"
      ]
    }
  ]
}
EOF
}
