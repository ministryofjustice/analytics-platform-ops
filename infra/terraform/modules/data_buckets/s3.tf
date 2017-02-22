resource "aws_s3_bucket" "source" {
    bucket = "${var.env}-moj-analytics-source"
    acl = "private"

    tags {
        Name = "${var.env}-moj-analytics-source"
    }
}

resource "aws_s3_bucket" "scratch" {
    bucket = "${var.env}-moj-analytics-scratch"
    acl = "private"

    tags {
        Name = "${var.env}-moj-analytics-scratch"
    }
}

resource "aws_s3_bucket" "logs" {
    bucket = "${var.env}-moj-analytics-logs"
    acl = "private"

    tags {
        Name = "${var.env}-moj-analytics-logs"
    }
}

# Data in the 'source' bucket must be encrypted
resource "aws_s3_bucket_policy" "source" {
    bucket = "${aws_s3_bucket.source.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyIncorrectEncryptionHeaderInSource",
      "Effect": "Deny",
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.source.arn}/*",
      "Principal": "*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "DenyUnEncryptedObjectUploadsInSource",
      "Effect": "Deny",
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.source.arn}/*",
      "Principal": "*",
      "Condition": {
        "Null": {
          "s3:x-amz-server-side-encryption": true
        }
      }
    }
  ]
}
EOF
}

# Data in the 'scratch' bucket must be encrypted (at least for now)
resource "aws_s3_bucket_policy" "scratch" {
    bucket = "${aws_s3_bucket.scratch.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyIncorrectEncryptionHeaderInScratch",
      "Effect": "Deny",
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.scratch.arn}/*",
      "Principal": "*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "DenyUnEncryptedObjectUploadsInScratch",
      "Effect": "Deny",
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.scratch.arn}/*",
      "Principal": "*",
      "Condition": {
        "Null": {
          "s3:x-amz-server-side-encryption": true
        }
      }
    }
  ]
}
EOF
}
