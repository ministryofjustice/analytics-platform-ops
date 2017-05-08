variable "name" {}
variable "domain_name" {}
variable "vpc_cidr" {}
variable "dns_zone_id" {}

variable "ingress_ips" {
    type = "list"
}

variable "es_version" {
    default = "2.3"
}

variable "instance_type" {
    default = "t2.small.elasticsearch"
}

variable "instance_count" {
    default = 1
}

variable "dedicated_master_enabled" {
    default = false
}

variable "dedicated_master_type" {
    default = ""
}

variable "dedicated_master_count" {
    default = 0
}

variable "ebs_enabled" {
    default = true
}

variable "ebs_volume_size" {
    default = 10
}

variable "ebs_volume_type" {
    default = "gp2"
}


output "arn" {
    value = "${aws_elasticsearch_domain.logging.arn}"
}

output "domain_id" {
    value = "${aws_elasticsearch_domain.logging.domain_id}"
}

output "endpoint" {
    value = "${aws_elasticsearch_domain.logging.endpoint}"
}
