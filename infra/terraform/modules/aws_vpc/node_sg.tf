resource "aws_security_group" "node_extra" {
    name = "node_extra"
    description = "Extra non-Kops-managed node SG to use as target for other SG rules"
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "node-extra.${var.name}"
        Cluster = "${var.name}"
    }
}
