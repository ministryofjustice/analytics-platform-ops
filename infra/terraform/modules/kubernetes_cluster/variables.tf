variable "supported_k8s_versions" {
  type = "list"

  default = [
    "1.6.9",
    "1.7.0",
    "1.7.1",
    "1.7.2",
    "1.7.3",
    "1.7.4",
    "1.7.5",
  ]
}

variable "availability_zones" {
  type = "list"
}

# Name for the cluster
variable "cluster_name" {}

# Fully qualified DNS name of cluster
variable "cluster_fqdn" {}

# ID of the VPC
variable "vpc_id" {}

# Route53 zone ID
variable "route53_zone_id" {}

# ARN of the kops bucket
variable "kops_s3_bucket_arn" {}

# ID of the kops bucket
variable "kops_s3_bucket_id" {}

# Name of the SSH key to use for cluster nodes and master
variable "instance_key_name" {}

# Security group ID to allow SSH from. Nodes and masters are added to this security group
variable "sg_allow_ssh" {}

# Security group ID to allow HTTP/S from. Master ELB is added to this security group
variable "sg_allow_http_s" {}

# A list of public subnet IDs
variable "vpc_public_subnet_ids" {
  type = "list"
}

# A list of private subnet IDs
variable "vpc_private_subnet_ids" {
  type = "list"
}

# IAM instance profile to use for the master
variable "master_iam_instance_profile" {}

# Instance type for the master
variable "master_instance_type" {
  default = "m3.medium"
}

# IAM instance profile to use for the nodes
variable "node_iam_instance_profile" {}

# Instance type for nodes
variable "node_instance_type" {
  default = "t2.medium"
}

# Node autoscaling group min
variable "node_asg_min" {
  default = 3
}

# Node autoscaling group desired
variable "node_asg_desired" {
  default = 3
}

# Node autoscaling group max
variable "node_asg_max" {
  default = 3
}

# Kubernetes version tag to use
variable "kubernetes_version" {
  default = "1.7.5"
}

# Cloudwatch log group log retention in days
variable "cloudwatch_log_group_retention" {
  default = 30
}

# kops DNS setting
variable "dns" {
  default = "public"
}

# Force single master. Can be used when a master per AZ is not required or if running in a region with only 2 AZs.
variable "force_single_master" {
  default = false
}

variable "vpc_cidr" {}

variable "node_volume_size" {
  default = 128
}

variable "bastion_instance_type" {
  default = "t2.small"
}

variable "bastion_asg_desired" {
  default = 3
}

variable "kops_ami_names" {
  type = "map"

  default = {
    "1.6" = "k8s-1.6-debian-jessie-amd64-hvm-ebs-2017-05-02"
    "1.7" = "k8s-1.7-debian-jessie-amd64-hvm-ebs-2017-07-28"
  }
}

variable "vpc_public_subnet_zones" {
  type = "map"
}

variable "vpc_private_subnet_zones" {
  type = "map"
}

variable "vpc_public_subnet_cidrs" {
  type = "map"
}

variable "vpc_private_subnet_cidrs" {
  type = "map"
}

variable "vpc_nat_gateway_subnets" {
  type = "map"
}

variable "ssh_public_key" {}
