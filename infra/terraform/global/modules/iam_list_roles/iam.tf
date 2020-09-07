resource "aws_iam_user" "system" {
  name = "${var.org_name}_${var.system_name}_iam_roles_readonly"
  path = "/uploaders/${var.org_name}/"
}

resource "aws_iam_access_key" "system_user" {
  user = "${aws_iam_user.system.name}"
}

data "aws_iam_policy_document" "iam_roles_readonly" {
  statement {
    actions = [
      "iam:ListRoles",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "iam_roles_readonly" {
  name   = "${var.org_name}_${var.system_name}_iam_roles_readonly"
  path   = "/iam/${var.org_name}/${var.system_name}/"
  policy = "${data.aws_iam_policy_document.iam_roles_readonly.json}"
}

resource "aws_iam_user_policy_attachment" "concourse_list_roles" {
  user       = "${aws_iam_user.system.name}"
  policy_arn = "${aws_iam_policy.iam_roles_readonly.arn}"
}
