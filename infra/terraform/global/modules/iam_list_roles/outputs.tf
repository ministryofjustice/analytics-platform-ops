output "access_key_id" {
  value = aws_iam_access_key.system_user.id
}

output "access_key_secret" {
  value = aws_iam_access_key.system_user.secret
}
