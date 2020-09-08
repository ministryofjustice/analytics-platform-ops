resource "aws_flow_log" "vpcflowlogs_to_s3" {
  iam_role_arn         = "${aws_iam_role.vpcflowlogs_to_elasticsearch_role.arn}"
  log_destination_type = "s3"
  log_destination      = "${aws_s3_bucket.vpcflowlogs_bucket.arn}"
  traffic_type         = "ALL"
  vpc_id               = "${var.vpc_id}"
}
