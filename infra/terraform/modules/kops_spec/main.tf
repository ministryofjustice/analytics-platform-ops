data "template_file" "etcd_member" {
  template = "${file("${path.module}/templates/etcd-member.snippet.tmpl")}"
  count    = "${length(var.availability_zones)}"

  vars {
    availability_zone = "${element(var.availability_zones, count.index)}"
  }
}

data "template_file" "public_subnet" {
  template = "${file("${path.module}/templates/subnet.snippet.tmpl")}"

  # Using AZs for count here instead of public_subnet_ids (or other subnet property)
  # due to limitations on using length() with computed module outputs. See:
  # https://github.com/hashicorp/terraform/issues/12570
  count = "${length(var.availability_zones)}"

  vars {
    subnet_type              = "Utility"
    subnet_name_prefix       = "dmz-"
    subnet_id                = "${element(var.public_subnet_ids, count.index)}"
    subnet_cidr_block        = "${element(var.public_subnet_cidr_blocks, count.index)}"
    subnet_availability_zone = "${element(var.public_subnet_availability_zones, count.index)}"
  }
}

data "template_file" "private_subnet" {
  template = "${file("${path.module}/templates/subnet.snippet.tmpl")}"
  count    = "${length(var.availability_zones)}"

  vars {
    subnet_type              = "Private"
    subnet_name_prefix       = ""
    subnet_id                = "${element(var.private_subnet_ids, count.index)}"
    subnet_cidr_block        = "${element(var.private_subnet_cidr_blocks, count.index)}"
    subnet_availability_zone = "${element(var.private_subnet_availability_zones, count.index)}"
  }
}

data "template_file" "master_instancegroup" {
  template = "${file("${path.module}/templates/instancegroup.snippet.tmpl")}"
  count    = "${length(var.availability_zones)}"

  vars {
    role                      = "Master"
    name                      = "master-${element(var.availability_zones, count.index)}"
    cluster_dns_name          = "${var.cluster_dns_name}"
    additional_security_group = "${var.masters_extra_sg_id}"
    image                     = "${var.instancegroup_image}"
    machine_type              = "${var.masters_machine_type}"
    max_size                  = 1
    min_size                  = 1
    subnets                   = "  - ${element(var.availability_zones, count.index)}"
  }
}

resource "local_file" "kops" {
  content  = "${data.template_file.kops.rendered}"
  filename = "../../kops/${terraform.workspace}.yaml"
}

data "template_file" "kops" {
  template = "${file("${path.module}/templates/kops.yaml.tmpl")}"

  vars {
    cluster_dns_name = "${var.cluster_dns_name}"
    cluster_dns_zone = "${var.cluster_dns_zone}"

    etcd_main_members   = "${join("", data.template_file.etcd_member.*.rendered)}"
    etcd_events_members = "${join("", data.template_file.etcd_member.*.rendered)}"

    public_subnets  = "${join("", data.template_file.public_subnet.*.rendered)}"
    private_subnets = "${join("", data.template_file.private_subnet.*.rendered)}"

    master_instancegroups = "${join("\n---\n", data.template_file.master_instancegroup.*.rendered)}"
  }
}
