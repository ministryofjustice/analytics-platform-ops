resource "aws_s3_bucket" "kops_state" {
    bucket = "${var.kops_bucket_name}"
    region = "${var.region}"
    acl = "private"

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "${var.terraform_bucket_name}"
    region = "${var.region}"
    acl = "private"

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
}

resource "aws_kms_key" "s3_uploads" {
    description = "Key for upload object encryption"
    deletion_window_in_days = 10
}

resource "aws_s3_bucket" "uploads" {
    bucket = "${var.uploads_bucket_name}"
    region = "${var.region}"
    acl = "private"

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                kms_master_key_id = "${aws_kms_key.s3_uploads.arn}"
                sse_algorithm     = "aws:kms"
            }
        }
    }
}
