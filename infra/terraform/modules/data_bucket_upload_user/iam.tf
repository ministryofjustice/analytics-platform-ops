resource "aws_iam_user" "system" {
  name = "${var.system_name}_uploader"
  path = "/uploaders/"
}

resource "aws_iam_access_key" "system_user" {
  user = "${aws_iam_user.system.name}"
}

data "aws_iam_policy_document" "system_user_s3_upload_readwrite" {
  statement {
    actions = [
      "s3:ListMultipartUploadParts",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersion",
      "s3:RestoreObject",
    ]

    effect = "Allow"

    resources = [
      "${var.upload_bucket_arn}/",
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

data "aws_iam_policy_document" "system_policy_s3_readonly" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:ListBucket",
    ]

    effect = "Allow"

    resources = [
      "${var.upload_bucket_arn}/",
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
}

resource "aws_iam_policy" "system_user_s3_readonly" {
  name   = "${var.system_name}_s3_readonly"
  path   = "/uploaders/${var.system_name}/"
  policy = "${data.aws_iam_policy_document.system_policy_s3_readonly.json}"
}
