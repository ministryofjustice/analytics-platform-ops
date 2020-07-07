resource "aws_iam_role" "control_panel_api" {
  name        = "${var.env}_control_panel_api"
  description = "IAM role assumed by the Control Panel API"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.k8s_worker_role_arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "control_panel_api" {
  name = "${var.env}_control_panel_api"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanCreateBuckets",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:PutBucketLogging",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutEncryptionConfiguration",
        "s3:PutBucketVersioning",
        "s3:PutLifecycleConfiguration"
      ],
      "Resource": [
        "arn:aws:s3:::${var.env}-*"
      ]
    },
    {
      "Sid": "CanTagBuckets",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketTagging",
        "s3:PutBucketTagging"
      ],
      "Resource": [
        "arn:aws:s3:::${var.env}-*"
      ]
    },
    {
      "Sid": "CanCreateIAMPolicies",
      "Effect": "Allow",
      "Action": [
        "iam:CreatePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:policy/${var.env}-*"
      ]
    },
    {
      "Sid": "CanDeleteIAMPolicies",
      "Effect": "Allow",
      "Action": [
        "iam:DeletePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:policy/${var.env}-*"
      ]
    },
    {
      "Sid": "CanDetachPolicies",
      "Effect": "Allow",
      "Action": [
        "iam:ListEntitiesForPolicy",
        "iam:DetachGroupPolicy",
        "iam:DetachRolePolicy",
        "iam:DetachUserPolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:*"
      ]
    },
    {
      "Sid": "CanAttachPolicy",
      "Effect": "Allow",
      "Action": [
        "iam:AttachRolePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:role/${var.env}_user_*",
        "arn:aws:iam::${var.account_id}:role/${var.env}_app_*"
      ]
    },
    {
      "Sid": "CanCreateRoles",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:role/${var.env}_user_*",
        "arn:aws:iam::${var.account_id}:role/${var.env}_app_*"
      ]
    },
    {
      "Sid": "CanDeleteRoles",
      "Effect": "Allow",
      "Action": [
        "iam:GetRole",
        "iam:DeleteRole",
        "iam:ListAttachedRolePolicies",
        "iam:ListRolePolicies",
        "iam:DetachRolePolicy",
        "iam:DeleteRolePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:role/${var.env}_user_*",
        "arn:aws:iam::${var.account_id}:role/${var.env}_app_*"
      ]
    },
    {
      "Sid": "CanReadRolesInlinePolicies",
      "Effect": "Allow",
      "Action": [
        "iam:GetRolePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:role/${var.env}_user_*",
        "arn:aws:iam::${var.account_id}:role/${var.env}_app_*"
      ]
    },
    {
      "Sid": "CanUpdateRolesInlinePolicies",
      "Effect": "Allow",
      "Action": [
        "iam:PutRolePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:role/${var.env}_user_*",
        "arn:aws:iam::${var.account_id}:role/${var.env}_app_*"
      ]
    },
    {
      "Sid": "CanListPoliciesForLambdaMigration",
      "Effect": "Allow",
      "Action": [
        "iam:ListPolicies"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:*"
      ]
    },
    {
      "Sid": "CanCreateAndDeleteSSMParameters",
      "Effect": "Allow",
      "Action": [
        "ssm:PutParameter",
        "ssm:DeleteParameter",
        "ssm:GetParameterHistory",
        "ssm:GetParametersByPath",
        "ssm:DeleteParameter",
        "ssm:DeleteParameters",
        "ssm:AddTagsToResource"
      ],
      "Resource": [
        "arn:aws:ssm:*:${var.account_id}:parameter/${var.env}*"
      ]
    },
    {
      "Sid": "CanListRoles",
      "Effect": "Allow",
      "Action": [
        "iam:ListRoles"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:role/*"
      ]
    },
    {
      "Sid": "CanManagePolicies",
      "Effect": "Allow",
      "Action": [
        "iam:CreatePolicy",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicy",
        "iam:DeletePolicyVersion",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:ListPolicyVersions",
        "iam:ListPolicies",
        "iam:ListEntitiesForPolicy",
        "iam:DetachRolePolicy",
        "iam:AttachRolePolicy"
      ],
      "Resource": [
        "arn:aws:iam::${var.account_id}:policy/${var.env}/group/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "control_panel_api" {
  role       = "${aws_iam_role.control_panel_api.name}"
  policy_arn = "${aws_iam_policy.control_panel_api.arn}"
}
