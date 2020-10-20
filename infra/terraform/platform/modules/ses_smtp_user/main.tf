resource "aws_iam_user" "smtp_user" {
  name = var.iam_user_name
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.smtp_user.name
}

resource "aws_iam_user_policy" "smtp_user_policy" {
  name = "${aws_iam_user.smtp_user.name}_policy"
  user = aws_iam_user.smtp_user.name

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
        "Resource": "${var.ses_address_identity_arn}"
    }
  ]
}
EOF

}

