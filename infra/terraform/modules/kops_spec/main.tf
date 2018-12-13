data "template_file" "etcd_member" {
  template = "${file("${path.module}/templates/etcd-member.snippet.tmpl")}"
  count    = "${length(var.availability_zones)}"

  vars {
    availability_zone = "${element(var.availability_zones, count.index)}"
  }
}

data "template_file" "public_subnet" {
  template = "${file("${path.module}/templates/subnet.snippet.tmpl")}"
  count    = "${length(var.public_subnet_availability_zones)}"

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
  count    = "${length(var.private_subnet_availability_zones)}"

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
  count    = "${length(var.private_subnet_availability_zones)}"

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

data "template_file" "nodes_instancegroup" {
  template = "${file("${path.module}/templates/instancegroup.snippet.tmpl")}"

  vars {
    role                      = "Node"
    name                      = "nodes"
    cluster_dns_name          = "${var.cluster_dns_name}"
    additional_security_group = "${var.nodes_extra_sg_id}"
    image                     = "${var.instancegroup_image}"
    machine_type              = "${var.nodes_machine_type}"
    max_size                  = "${var.nodes_instancegroup_max_size}"
    min_size                  = "${var.nodes_instancegroup_max_size}"
    subnets                   = "  - ${join("\n  - ", var.private_subnet_availability_zones)}"
  }
}

data "template_file" "highmem_nodes_instancegroup" {
  template = "${file("${path.module}/templates/instancegroup.snippet.tmpl")}"

  vars {
    role                      = "Node"
    name                      = "highmem-nodes"
    cluster_dns_name          = "${var.cluster_dns_name}"
    additional_security_group = "${var.nodes_extra_sg_id}"
    image                     = "${var.instancegroup_image}"
    machine_type              = "${var.highmem_nodes_machine_type}"
    max_size                  = "${var.highmem_nodes_instancegroup_max_size}"
    min_size                  = "${var.highmem_nodes_instancegroup_max_size}"
    subnets                   = "  - ${join("\n  - ", var.private_subnet_availability_zones)}"
  }
}

data "template_file" "bastions_instancegroup" {
  template = "${file("${path.module}/templates/instancegroup.snippet.tmpl")}"

  vars {
    role                      = "Bastion"
    name                      = "bastions"
    cluster_dns_name          = "${var.cluster_dns_name}"
    additional_security_group = "${var.bastions_extra_sg_id}"
    image                     = "${var.instancegroup_image}"
    machine_type              = "${var.bastions_machine_type}"
    max_size                  = "${var.bastions_instancegroup_max_size}"
    min_size                  = "${var.bastions_instancegroup_max_size}"
    subnets                   = "  - ${join("\n  - ", var.public_subnet_availability_zones)}"
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

    kops_state_bucket  = "${var.kops_state_bucket}"
    oidc_client_id     = "${var.oidc_client_id}"
    oidc_issuer_url    = "${var.oidc_issuer_url}"
    kubernetes_version = "${var.kubernetes_version}"
    vpc_id             = "${var.vpc_id}"
    vpc_cidr           = "${var.vpc_cidr}"

    etcd_main_members   = "${join("", data.template_file.etcd_member.*.rendered)}"
    etcd_events_members = "${join("", data.template_file.etcd_member.*.rendered)}"

    public_subnets  = "${join("", data.template_file.public_subnet.*.rendered)}"
    private_subnets = "${join("", data.template_file.private_subnet.*.rendered)}"

    master_instancegroups       = "${join("\n---\n", data.template_file.master_instancegroup.*.rendered)}"
    nodes_instancegroup         = "${data.template_file.nodes_instancegroup.rendered}"
    highmem_nodes_instancegroup = "${data.template_file.highmem_nodes_instancegroup.rendered}"
    bastions_instancegroup      = "${data.template_file.bastions_instancegroup.rendered}"
  }
}
