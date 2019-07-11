output "access_key_id" {
  value = "${aws_iam_access_key.parameter_user_key.id}"
}

output "access_key_secret" {
  value = "${aws_iam_access_key.parameter_user_key.secret}"
}
