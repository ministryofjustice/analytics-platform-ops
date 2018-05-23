resource "aws_iam_user" "system" {
  name = "${var.org_name}_${var.system_name}_uploader"
  path = "/uploaders/${var.org_name}/"
}

resource "aws_iam_access_key" "system_user" {
  user = "${aws_iam_user.system.name}"
}

data "aws_iam_policy_document" "system_user_s3_upload_writeonly" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:ListMultipartUploadParts",
    ]

    effect = "Allow"

    resources = [
      "${var.upload_bucket_arn}/${var.org_name}/${var.system_name}/*",
    ]
  }
}

resource "aws_iam_policy" "system_user_s3_writeonly" {
  name   = "${var.org_name}_${var.system_name}_s3_upload_writeonly"
  path   = "/uploaders/${var.org_name}/${var.system_name}/"
  policy = "${data.aws_iam_policy_document.system_user_s3_upload_writeonly.json}"
}

resource "aws_iam_user_policy_attachment" "system_user_s3_upload" {
  user       = "${aws_iam_user.system.name}"
  policy_arn = "${aws_iam_policy.system_user_s3_writeonly.arn}"
}
