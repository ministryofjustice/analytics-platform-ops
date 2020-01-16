resource "aws_iam_policy" "dlm_policy" {
  name   = "${var.name}-policy"
  policy = "${data.aws_iam_policy_document.dlm.json}"
}

resource "aws_iam_role" "dlm_role" {
  name                  = "${var.name}-role"
  assume_role_policy    = "${data.aws_iam_policy_document.assume.json}"
  force_detach_policies = true
}

resource "aws_iam_policy_attachment" "dlm_policy_policy_attachment" {
  name       = "${var.name}-policy-attachment"
  policy_arn = "${aws_iam_policy.dlm_policy.arn}"
  roles      = ["${aws_iam_role.dlm_role.name}"]
}
