variable "region" {
  default = "eu-west-1"
}

variable "terraform_bucket_name" {}
variable "terraform_base_state_file" {}
variable "env" {}
variable "vpc_cidr" {}

variable "availability_zones" {
  type = "list"

  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c",
  ]
}

variable "ssh_public_key" {}

variable "kubernetes_version" {
  default = "1.7.5"
}

variable "num_nodes" {
  default = 3
}

variable "master_instance_type" {
  default = "m3.medium"
}

variable "node_instance_type" {
  default = "t2.medium"
}
