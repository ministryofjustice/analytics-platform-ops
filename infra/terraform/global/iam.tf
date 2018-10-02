resource "aws_iam_user" "auth0_ses" {
  name = "auth0_ses_user"
}

resource "aws_iam_user_policy" "auth0_ses" {
  name = "auth0_ses_user_policy"
  user = "${aws_iam_user.auth0_ses.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ses:SendRawEmail",
        "ses:SendEmail"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "auth0_ses" {
  user = "${aws_iam_user.auth0_ses.name}"
}

resource "aws_iam_role" "softnas" {
  name = "SoftNAS_HA_IAM"

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

resource "aws_iam_role_policy" "softnas" {
  name = "softnas_ha_policy"
  role = "${aws_iam_role.softnas.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1444200186000",
      "Effect": "Allow",
      "Action": [
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
        "s3:Put*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user" "concourse_update_helm_repo" {
  name = "concourse_update_helm_repo"
}

resource "aws_iam_access_key" "concourse_update_helm_repo_access_key" {
  user = "${aws_iam_user.concourse_update_helm_repo.name}"
}

resource "aws_iam_user_policy" "concourse_update_helm_repo_policy" {
  name = "${aws_iam_user.concourse_update_helm_repo.name}_policy"
  user = "${aws_iam_user.concourse_update_helm_repo.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "UpdateHelmRepoS3Bucket",
        "Effect": "Allow",
        "Action": [
            "s3:PutObject",
            "s3:GetObject"
        ],
        "Resource": [
            "arn:aws:s3:::${var.helm_repo_s3_bucket_name}/*"
        ]
    }]
}
EOF
}
