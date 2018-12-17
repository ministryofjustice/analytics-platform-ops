resource "aws_s3_bucket" "s3_logs" {
  bucket = "${var.s3_logs_bucket_name}"
  acl    = "log-delivery-write"

  lifecycle_rule {
    id                                     = "logs-transition"
    prefix                                 = ""
    abort_incomplete_multipart_upload_days = 7
    enabled                                = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }

  tags {
    Name = "moj-analytics-s3-logs"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "vpcflowlogs_bucket" {
  bucket = "${var.vpcflowlogs_s3_bucket_name}"

  lifecycle_rule {
    enabled                                = true
    id                                     = "logs-transition"
    abort_incomplete_multipart_upload_days = 7

    transition {
      storage_class = "STANDARD_IA"
      days          = 30
    }

    transition {
      storage_class = "GLACIER"
      days          = 60
    }

    expiration {
      days = 365
    }
  }

  tags {
    Name = "moj-analytics-vpcflowlogs"
  }
}
