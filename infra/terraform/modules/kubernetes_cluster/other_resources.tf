resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/kubernetes/cluster/${var.cluster_fqdn}"
  retention_in_days = "${var.cloudwatch_log_group_retention}"
}
