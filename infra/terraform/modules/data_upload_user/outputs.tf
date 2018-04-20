output "system_user_access_key_id" {
  value = "${aws_iam_access_key.system_user.id}"
}

output "system_user_access_key_secret" {
  value = "${aws_iam_access_key.system_user.secret}"
}
