# Some awful nonsense to get the Atlantis ECS role name from its ARN.
# The Atlantis module outputs the role ARN, but Terraform resources
# take the role name as an argument, not ARN
locals {
    ecs_role_arn_parts = "${split("/", var.atlantis_ecs_role_arn)}"
    ecs_role_name = "${element(local.ecs_role_arn_parts, length(local.ecs_role_arn_parts) - 1)}"
}

data "aws_iam_policy_document" "atlantis_terraform" {
  statement {
    actions = ["ec2:*"]
    resources = ["*"]
    effect = "Allow"
  }

  statement {
      actions = ["s3:ListBucket"]
      resources = ["arn:aws:s3:::${var.terraform_state_bucket_name}"]
      effect = "Allow"
  }

  statement {
      actions = [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject"
      ]
      resources = ["arn:aws:s3:::${var.terraform_state_bucket_name}/*"]
      effect = "Allow"
  }

  statement {
      actions = [
          "s3:CreateBucket"
      ]
      resources = ["arn:aws:s3:::*"]
      effect = "Allow"
  }

  statement {
      actions = [
          "s3:*"
      ]
      resources = ["arn:aws:s3:::${var.test_bucket_name}"]
      effect = "Allow"
  }
}

resource "aws_iam_policy" "atlantis_terraform" {
  name   = "atlantis-terraform"
  policy = "${data.aws_iam_policy_document.atlantis_terraform.json}"
}

resource "aws_iam_role_policy_attachment" "atlantis_ecs_terraform" {
  role = "${local.ecs_role_name}"
  policy_arn = "${aws_iam_policy.atlantis_terraform.arn}"
}
