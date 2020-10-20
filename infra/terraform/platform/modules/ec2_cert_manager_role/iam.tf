data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"

    principals {
      identifiers = var.trusted_entity
      type        = "AWS"
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${var.hosted_zone_id}"]
  }

  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "role" {
  assume_role_policy = data.aws_iam_policy_document.assume.json
  name               = var.role_name
}

resource "aws_iam_policy" "policy" {
  name   = var.role_name
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_policy_attachment" "policy_attachement" {
  name       = var.role_name
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy.arn
}

