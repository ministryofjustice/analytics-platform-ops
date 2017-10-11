resource "aws_iam_role" "nfs_backup" {
  name = "${var.env}_nfs_backup"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_policy" "nfs_backup" {
  name = "${var.env}_nfs_backup"
  description = "Policy for S3 write for NFS backup processes"
  policy = "${data.aws_iam_policy_document.nfs_backup.json}"
}

resource "aws_iam_policy_attachment" "nfs_backup" {
  name = "${var.env}_nfs_backup"
  roles = ["${aws_iam_role.nfs_backup.name}"]
  policy_arn = "${aws_iam_policy.nfs_backup.arn}"
}
