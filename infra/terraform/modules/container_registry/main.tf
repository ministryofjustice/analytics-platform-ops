output "jenkinsci_access_key_id" {
  value = "${aws_iam_access_key.jenkinsci.id}"
}

output "jenkinsci_access_key_secret" {
  value = "${aws_iam_access_key.jenkinsci.secret}"
}
