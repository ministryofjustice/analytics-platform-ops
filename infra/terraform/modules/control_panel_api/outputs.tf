output "db_host" {
  value = "${aws_db_instance.control_panel_db.address}"
}

output "iam_role_name" {
  value = "${aws_iam_role.control_panel_api.name}"
}
