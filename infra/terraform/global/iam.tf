resource "aws_iam_user" "auth0_ses" {
  name = "auth0_ses_user"
}

resource "aws_iam_user_policy" "auth0_ses" {
  name   = "auth0_ses_user_policy"
  user   = aws_iam_user.auth0_ses.name
  policy = data.aws_iam_policy_document.auth0_ses.json
}

data "aws_iam_policy_document" "auth0_ses" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ses:SendRawEmail",
      "ses:SendEmail",
    ]
  }
}

resource "aws_iam_access_key" "auth0_ses" {
  user = aws_iam_user.auth0_ses.name
}

resource "aws_iam_role" "softnas" {
  name               = "SoftNAS_HA_IAM"
  assume_role_policy = data.aws_iam_policy_document.softnas_role.json
}

data "aws_iam_policy_document" "softnas_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "softnas" {
  name   = "softnas_ha_policy"
  role   = aws_iam_role.softnas.id
  policy = data.aws_iam_policy_document.softnas.json
}

data "aws_iam_policy_document" "softnas" {
  statement {
    effect    = "Allow"
    sid       = "Stmt1444200186000"
    resources = ["*"]

    actions = [
      "ec2:ModifyInstanceAttribute",
      "ec2:DescribeInstances",
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
      "aws-marketplace:MeterUsage",
      "ec2:DescribeRouteTables",
      "ec2:DescribeAddresses",
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:ReplaceRoute",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:AssociateAddress",
      "ec2:DisassociateAddress",
      "s3:CreateBucket",
      "s3:Delete*",
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
    ]
  }
}

resource "aws_iam_user" "concourse_update_helm_repo" {
  name = "concourse_update_helm_repo"
}

resource "aws_iam_access_key" "concourse_update_helm_repo_access_key" {
  user = aws_iam_user.concourse_update_helm_repo.name
}

resource "aws_iam_user_policy" "concourse_update_helm_repo_policy" {
  name   = "${aws_iam_user.concourse_update_helm_repo.name}_policy"
  user   = aws_iam_user.concourse_update_helm_repo.name
  policy = data.aws_iam_policy_document.concourse.json
}

data "aws_iam_policy_document" "concourse" {
  statement {
    effect    = "Allow"
    sid       = "UpdateHelmRepoS3Bucket"
    resources = ["arn:aws:s3:::${var.helm_repo_s3_bucket_name}/*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]
  }
}
