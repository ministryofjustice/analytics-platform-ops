output "airflow_db_host" {
  value = module.airflow_db.address
}

output "airflow_efs_host" {
  value = module.airflow_storage_efs_volume.dns_name
}

output "region" {
  value = var.region
}

output "terraform_bucket_name" {
  value = var.terraform_bucket_name
}

output "terraform_global_state_file" {
  value = var.terraform_global_state_file
}

output "softnas_ssh_public_key" {
  value = var.softnas_ssh_public_key
}

output "softnas_num_instances" {
  value = var.softnas_num_instances
}

output "softnas_default_volume_size" {
  value = var.softnas_default_volume_size
}

output "softnas_ami_id" {
  value = var.softnas_ami_id
}

output "softnas_instance_type" {
  value = var.softnas_instance_type
}

output "airflow_db_username" {
  value = var.airflow_db_username
}

output "airflow_db_password" {
  value = var.airflow_db_password
}

output "airflow_smtp_username" {
  value = module.airflow_smtp_user.smtp_username
}

# output "airflow_smtp_password" {
#   value = module.airflow_smtp_user.smtp_password
# }

output "control_panel_api_db_username" {
  value = var.control_panel_api_db_username
}

output "control_panel_api_db_password" {
  value = var.control_panel_api_db_password
}

output "control_panel_api_db_host" {
  value = module.control_panel_api.db_host
}

output "concourse_parameter_user_access_key_id" {
  value = module.concourse_parameter_user.access_key_id
}

output "concourse_parameter_user_access_key_secret" {
  value = module.concourse_parameter_user.access_key_secret
}

