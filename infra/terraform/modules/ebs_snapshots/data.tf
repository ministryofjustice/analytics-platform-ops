data "aws_iam_policy_document" "assume" {
  statement {
    sid = "assume"

    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["dlm.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "dlm" {
  statement {
    sid = "CreateTags"

    effect = "Allow"

    actions = [
      "ec2:CreateTags",
    ]

    resources = ["arn:aws:ec2:*::snapshot/*"]
  }

  statement {
    sid = "ManageSnapshots"

    effect = "Allow"

    actions = [
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
    ]

    resources = ["*"]
  }
}
