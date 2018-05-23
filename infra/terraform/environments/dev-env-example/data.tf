data "aws_caller_identity" "current" {}

data "terraform_remote_state" "base" {
  backend = "s3"

  config {
    bucket = "${var.terraform_bucket_name}"
    region = "${var.region}"
    key    = "${var.terraform_base_state_file}"
  }
}
