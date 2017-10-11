resource "aws_s3_bucket" "nfs_backup" {
  bucket = "${var.env}-moj-analytics-nfs-backup"
  region = "${data.aws_region.current.name}"
  acl = "private"

  tags {
    Name = "${var.env}-moj-analytics-nfs-backup"
  }

  lifecycle_rule {
    id = "${var.env}-nfs-backup-transition"
    abort_incomplete_multipart_upload_days = "${var.abort_incomplete_multipart_upload_days}"
    enabled = true

    transition {
      days          = "${var.backup_glacier_transition_days}"
      storage_class = "GLACIER"
    }

    expiration {
      days = "${var.backup_expiration_days}"
    }
  }
}
