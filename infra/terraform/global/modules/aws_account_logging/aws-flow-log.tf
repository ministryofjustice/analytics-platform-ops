resource "aws_flow_log" "vpcflowlogs_to_s3" {
  iam_role_arn         = aws_iam_role.vpcflowlogs_to_elasticsearch_role.arn
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.vpcflowlogs_bucket.arn
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
}

# TODO: Apply to both Alpha and Dev VPCs
# resource "aws_flow_log" "log" {
#   iam_role_arn         = aws_iam_role.vpc_flowlogs.arn
#   log_destination_type = "cloud-watch-logs"
#   log_destination      = aws_cloudwatch_log_group.vpc_flowlogs.arn
#   traffic_type         = "REJECT"
#   vpc_id               = var.vpc_id
# }

# resource "aws_cloudwatch_log_group" "vpc_flowlogs" {
#   name_prefix       = "VPC-Flow-Logs"
#   retention_in_days = "7"
#   tags              = var.tags
# }
