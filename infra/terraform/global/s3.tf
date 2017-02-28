resource "aws_s3_bucket" "kops_state" {
    bucket = "${var.kops_bucket_name}"
    region = "${var.region}"
    acl = "private"
    versioning {
        enabled = true
    }
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "${var.terraform_bucket_name}"
    region = "${var.region}"
    acl = "private"
    versioning {
        enabled = true
    }
}
