output "ssh_key_name" {
  value = "${aws_key_pair.default_instance_key.key_name}"
}

output "ssh_public_key" {
  value = "${var.ssh_public_key}"
}

output "ssh_key_fingerprint" {
  value = "${aws_key_pair.default_instance_key.fingerprint}"
}
