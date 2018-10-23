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
