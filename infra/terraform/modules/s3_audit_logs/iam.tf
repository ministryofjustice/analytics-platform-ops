data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "WriteAuditS3Bucket"
    effect = "Allow"

    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::audit-security-logs-335823981503",
      "arn:aws:s3:::audit-security-logs-335823981503/*",
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "${var.policy_name}"
  policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_iam_policy_attachment" "policy_attachment" {
  name       = "${var.policy_name}"
  roles      = ["${var.instance_role_name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}
