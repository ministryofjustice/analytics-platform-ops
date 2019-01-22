data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]

    resources = ["${data.aws_autoscaling_groups.asgs.arns}"]
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
