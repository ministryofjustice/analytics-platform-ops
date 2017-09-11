output "inbound_ssh_sg_id" {
  value = "${aws_security_group.k8s_inbound_ssh.id}"
}

output "inbound_http_sg_id" {
  value = "${aws_security_group.k8s_inbound_http.id}"
}

output "masters_instance_profile_id" {
  value = "${aws_iam_instance_profile.kubernetes_masters.id}"
}

output "nodes_instance_profile_id" {
  value = "${aws_iam_instance_profile.kubernetes_nodes.id}"
}
