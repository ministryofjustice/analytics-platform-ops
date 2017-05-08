resource "aws_iam_user" "auth0_ses_user" {
    name = "auth0-ses-user"
}

resource "aws_iam_user_policy" "auth0-ses-user" {
    name = "auth0-ses-user"
    user = "${aws_iam_user.auth0_ses_user.name}"
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

resource "aws_iam_access_key" "auth0_ses_user" {
    user = "${aws_iam_user.auth0_ses_user.name}"
}
