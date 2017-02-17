resource "aws_security_group" "node_extra" {
    name = "node_extra"
    description = "Extra non-Kops-managed node SG to use as target for other SG rules"
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "node-extra.${var.name}"
        Cluster = "${var.name}"
    }
}

resource "aws_security_group" "master_extra" {
    name = "master_extra"
    description = "Extra non-Kops-managed master SG to use as target for other SG rules"
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "master-extra.${var.name}"
        Cluster = "${var.name}"
    }

    # Heapster / cAdvisor port access from worker nodes
    ingress {
        from_port = 10255
        to_port = 10255
        protocol = "tcp"
        security_groups = ["${aws_security_group.node_extra.id}"]
    }

    # Prometheus port
    ingress {
        from_port = 10250
        to_port = 10250
        protocol = "tcp"
        security_groups = ["${aws_security_group.node_extra.id}"]
    }
}
