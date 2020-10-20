resource "aws_iam_user" "parameter_user" {
  name = "${terraform.workspace}_${var.user_name}_parameter_readonly"
  path = "/parameter/"
}

resource "aws_iam_access_key" "parameter_user_key" {
  user = aws_iam_user.parameter_user.name
}

data "aws_iam_policy_document" "parameter_readonly_document" {
  statement {
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:ssm:*:*:parameter/${terraform.workspace}/webapp/*",
    ]
  }

  statement {
    actions = [
      "kms:Decrypt",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:kms:::key/*",
    ]
  }
}

resource "aws_iam_policy" "parameter_readonly_policy" {
  name   = "${terraform.workspace}_${var.user_name}_parameter_roles_readonly"
  path   = "/parameter/"
  policy = data.aws_iam_policy_document.parameter_readonly_document.json
}

resource "aws_iam_user_policy_attachment" "concourse_parameter" {
  user       = aws_iam_user.parameter_user.name
  policy_arn = aws_iam_policy.parameter_readonly_policy.arn
}

