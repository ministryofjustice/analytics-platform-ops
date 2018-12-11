data "aws_caller_identity" "current" {}

data "terraform_remote_state" "global" {
  backend = "s3"

  config {
    bucket = "${var.terraform_bucket_name}"
    region = "${var.region}"
    key    = "${var.terraform_global_state_file}"
  }
}
