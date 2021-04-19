variable "region" {
  default = "eu-west-1"
}

variable "terraform_bucket_name" {
}

variable "terraform_global_state_file" {
  default = "base/terraform.tfstate"
}

variable "softnas_ssh_public_key" {
}

variable "softnas_num_instances" {
  type    = number
  default = 2
}

variable "is_production" {
  default = "true"
}

variable "tags" {
  type        = map(string)
  description = "tags resources will have, e.g. 'application', 'env' or 'is-production' etc...modules could add more"
}

variable "softnas_default_volume_size" {
  default = 10
}

variable "softnas_ami_id" {
  default = "ami-6498ac02"
}

variable "softnas_instance_type" {
  default = "m4.large"
}

variable "softnas_volume_size" {
  default = "10" # GB
}

variable "control_panel_api_db_username" {
}

variable "control_panel_api_db_password" {
}

variable "control_panel_redis_node_type" {
}

variable "control_panel_redis_password" {
}

variable "airflow_db_username" {
}

variable "airflow_db_password" {
}

variable "ses_ap_email_identity_arn" {
}

variable "softnas_cpu_low_threshold" {
}

variable "k8s_desired_capacity_threshold" {
}

variable "platform_root_domain" {
  type = string
}

variable "log_bucket_name" {
  type        = string
  description = "Bucket name to store logs in"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security groups and load balancers"
}

variable "softnas_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for fornas EBS volumes"
}

variable "dmz_subnet_ids" {
  type        = list(string)
  description = "IDs for DMZ subnets"
}

variable "bastion_host_key_pair" {
  type        = string
  description = "Name of key pair to use for Bastion servers"
}
