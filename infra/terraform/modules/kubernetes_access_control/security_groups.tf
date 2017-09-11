resource "aws_security_group" "k8s_inbound_ssh" {
    name = "inbound_ssh"
    vpc_id = "${var.vpc_id}"

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      security_groups = [
        "${var.inbound_ssh_source_sg_id}"
      ]
    }
}

resource "aws_security_group" "k8s_inbound_http" {
    name = "inbound_http"
    vpc_id = "${var.vpc_id}"

    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["${var.inbound_http_cidr_blocks}"]
    }

    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["${var.inbound_http_cidr_blocks}"]
    }
}
