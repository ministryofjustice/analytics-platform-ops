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
