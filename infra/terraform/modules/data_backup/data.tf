data "aws_region" "current" {
  current = true
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["${var.k8s_worker_role_arn}"]
    }
  }
}

data "aws_iam_policy_document" "nfs_backup" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.nfs_backup.arn}/*"
    ]
  }
}
