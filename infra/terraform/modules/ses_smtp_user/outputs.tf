output "password" {
  value = "${aws_iam_access_key.access_key.ses_smtp_password}"
}
