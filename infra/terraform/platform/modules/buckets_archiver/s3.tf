# S3 Bucket containing the data for archived S3 buckets
resource "aws_s3_bucket" "archived_buckets_data" {
  bucket = var.name
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    expiration {
      days = var.expiration_days
    }

    noncurrent_version_expiration {
      days = var.expiration_days
    }
  }

  logging {
    target_bucket = var.logging_bucket_name
    target_prefix = "${var.name}/"
  }

  tags = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "archived_buckets_data" {
  bucket = aws_s3_bucket.archived_buckets_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

