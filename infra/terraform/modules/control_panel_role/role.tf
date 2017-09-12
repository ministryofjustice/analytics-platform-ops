resource "aws_iam_role" "control_panel_api" {
    name = "${var.env}_control_panel_api"
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
            "s3:PutBucketLogging"
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
            "iam:DeleteRole",
            "iam:ListAttachedRolePolicies",
            "iam:DetachRolePolicy"
          ],
          "Resource": [
            "arn:aws:iam::${var.account_id}:role/${var.env}_user_*",
            "arn:aws:iam::${var.account_id}:role/${var.env}_app_*"
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
