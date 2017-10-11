resource "aws_s3_bucket" "nfs_backup" {
  bucket = "${var.env}-moj-analytics-nfs-backup"
  region = "${data.aws_region.current.name}"
  acl = "private"

  tags {
    Name = "${var.env}-moj-analytics-nfs-backup"
  }

  lifecycle_rule {
    id = "${var.env}-nfs-backup-transition"
    abort_incomplete_multipart_upload_days = 1
    enabled = true

    transition {
      days          = "30"
      storage_class = "GLACIER"
    }

    expiration {
      days = "90"
    }
  }
}
