data "aws_iam_policy_document" "analytics_logging_role_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]

    effect = "Allow"

    resources = ["${aws_s3_bucket.analytics_logging_bucket.arn}"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]

    effect = "Allow"

    resources = ["${aws_s3_bucket.analytics_logging_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "analytics_logging_policy" {
  policy = "${data.aws_iam_policy_document.analytics_logging_role_policy.json}"
  name   = "${var.name}"
}

resource "aws_iam_user_policy_attachment" "analytics_logging_user_policy_attachment" {
  user       = "${aws_iam_user.analytics_logging_user.name}"
  policy_arn = "${aws_iam_policy.analytics_logging_policy.arn}"
}

resource "aws_iam_user" "analytics_logging_user" {
  name = "${var.name}"
  path = "/"
}
