resource "aws_s3_bucket" "source" {
  bucket = "${var.env}-moj-analytics-source"
  acl    = "private"

  tags {
    Name = "${var.env}-moj-analytics-source"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "scratch" {
  bucket = "${var.env}-moj-analytics-scratch"
  acl    = "private"

  tags {
    Name = "${var.env}-moj-analytics-scratch"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

data "aws_iam_policy_document" "source_bucket" {
  statement {
    sid    = "DenyIncorrectEncryptionHeaderInSource"
    effect = "Deny"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.source.arn}/*",
    ]

    principals {
      type = "*"

      identifiers = [
        "*",
      ]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "AES256",
      ]
    }
  }

  statement {
    sid    = "DenyUnEncryptedObjectUploadsInSource"
    effect = "Deny"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.source.arn}/*",
    ]

    principals {
      type = "*"

      identifiers = [
        "*",
      ]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "true",
      ]
    }
  }
}

# Data in the 'source' bucket must be encrypted
resource "aws_s3_bucket_policy" "source" {
  bucket = "${aws_s3_bucket.source.id}"
  policy = "${data.aws_iam_policy_document.source_bucket.json}"
}
