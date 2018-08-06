output "airflow_db_host" {
  value = "${module.airflow_db.address}"
}

output "airflow_efs_host" {
  value = "${module.airflow_storage_efs_volume.dns_name}"
}

output "env" {
  value = "${var.env}"
}

# output "control_panel_api_db_host" {
#   value = "${module.control_panel_api.db_host}"
# }


# output "control_panel_api_iam_role_name" {
#   value = "${module.control_panel_api.iam_role_name}"
# }

