resource "aws_dlm_lifecycle_policy" "dlm_lifecycle" {
  description = "DLM Lifecycle Policy to take periodic EBS snapshots - ${terraform.workspace}"
  state       = "${var.lifecycle_state}"

  execution_role_arn = "${aws_iam_role.dlm_role.arn}"

  policy_details {
    resource_types = ["VOLUME"]
    target_tags    = "${var.target_tags}"

    schedule {
      name      = "Snapshots of EBS volumes every ${var.schedule_interval} ${var.schedule_interval_unit}"
      copy_tags = "${var.schedule_copy_tags}"

      create_rule {
        times         = ["${var.schedule_time}"]
        interval      = "${var.schedule_interval}"
        interval_unit = "${var.schedule_interval_unit}"
      }

      retain_rule {
        count = "${var.retain_count}"
      }

      tags_to_add = {
        SnapshotCreatedBy = "DLM (managed by Terraform)"
      }
    }
  }

  tags = "${merge(map(
    "Name", "${var.name}",
  ), var.tags)}"
}
