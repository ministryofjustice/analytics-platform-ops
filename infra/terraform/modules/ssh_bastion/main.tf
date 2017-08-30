variable "allowed_cidr" {
  type        = "list"
  default     = ["0.0.0.0/0"]
  description = "A list of CIDR Networks to allow SSH access from."
}

variable "name" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_id" {}

variable "subnet_ids" {
  default     = []
  description = "A list of subnet ids"
}

variable "key_name" {}

output "bastion_sg_id" {
  value = "${aws_security_group.bastion.id}"
}
