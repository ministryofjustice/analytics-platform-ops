output "aws_client_id" {
  value = "${auth0_client.aws.id}"
}

output "kubectl_oidc_client_id" {
  value = "${auth0_client.kubectl-oidc.id}"
}
