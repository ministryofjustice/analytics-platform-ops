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
