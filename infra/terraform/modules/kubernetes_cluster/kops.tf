resource "null_resource" "check_supported_k8s_version" {
  triggers {
    kubernetes_version  = "${var.kubernetes_version}"
    kubernetes_versions = "${join(",", sort(var.supported_k8s_versions))}"
  }

  provisioner "local-exec" {
    command = <<EOF
status=${contains(var.supported_k8s_versions, var.kubernetes_version) ? 0 : 1}
if [[ $status == "1" ]]
then
  echo "Kubernetes version ${var.kubernetes_version} not supported"
fi
exit $status
EOF
  }
}

resource "null_resource" "check_kops_version" {
  depends_on = [
    "null_resource.check_supported_k8s_version",
  ]

  provisioner "local-exec" {
    command = "${path.module}/bin/check_kops_version.sh ${path.module}/data/user_data.sh"
  }
}

resource "null_resource" "wait_for_dns_resolution" {
  provisioner "local-exec" {
    command = "${path.module}/bin/wait_for_dns_resolution.sh ${var.cluster_fqdn}"
  }
}

resource "null_resource" "create_cluster" {
  depends_on = [
    "null_resource.check_supported_k8s_version",
    "null_resource.check_kops_version",
    "null_resource.wait_for_dns_resolution",
  ]

  provisioner "local-exec" {
    command = <<EOF
${path.module}/bin/kops-specs/generate_specs.py \
  --template-path ${path.module}/data/kops \
  --out-path ${path.module}/out \
  --cluster-name ${var.cluster_fqdn} \
  --vpc-id ${var.vpc_id} \
  --state-bucket ${var.kops_s3_bucket_id} \
  --kubernetes-version ${var.kubernetes_version} \
  --dns-zone ${var.route53_zone_id} \
  --zones ${join(",", var.availability_zones)} \
  --network-cidr ${var.vpc_cidr} \
  --node-instance-type ${var.node_instance_type} \
  --node-count ${var.node_asg_desired} \
  --node-volume-size ${var.node_volume_size} \
  --ami-name ${data.aws_ami.kops_ami.id} \
  --bastion-instance-type ${var.bastion_instance_type} \
  --bastion-count ${var.bastion_asg_desired} \
  --master-instance-type ${var.master_instance_type} \
  --public-subnet-zones '${jsonencode(var.vpc_public_subnet_zones)}' \
  --private-subnet-zones '${jsonencode(var.vpc_private_subnet_zones)}' \
  --public-subnet-cidrs '${jsonencode(var.vpc_public_subnet_cidrs)}' \
  --private-subnet-cidrs '${jsonencode(var.vpc_private_subnet_cidrs)}' \
  --nat-gateway-subnets '${jsonencode(var.vpc_nat_gateway_subnets)}'


kops create -f ${path.module}/out/cluster.yml --state=s3://${var.kops_s3_bucket_id}
kops create -f ${path.module}/out/bastions.yml --state=s3://${var.kops_s3_bucket_id}
kops create -f ${path.module}/out/masters.yml --state=s3://${var.kops_s3_bucket_id}
kops create -f ${path.module}/out/nodes.yml --state=s3://${var.kops_s3_bucket_id}

echo "${var.ssh_public_key}" > ${path.module}/out/id_rsa.pub
kops create secret --name ${var.cluster_fqdn} sshpublickey admin \
  -i ${path.module}/out/id_rsa.pub --state=s3://${var.kops_s3_bucket_id}

kops update cluster ${var.cluster_fqdn} --target terraform \
  --state=s3://${var.kops_s3_bucket_id}

EOF
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kops delete cluster --yes --state=s3://${var.kops_s3_bucket_id} --unregister ${var.cluster_fqdn}"
  }
}

resource "null_resource" "wait_for_cluster_ready" {
  depends_on = ["null_resource.create_cluster"]

  provisioner "local-exec" {
    command = "${path.module}/bin/wait_for_cluster_ready.sh ${var.cluster_fqdn}"
  }
}

resource "null_resource" "update_cluster" {
  depends_on = [
    "null_resource.check_supported_k8s_version",
    "null_resource.check_kops_version",
    "null_resource.wait_for_cluster_ready",
  ]

  triggers {
    kubernetes_version    = "${var.kubernetes_version}"
    node_instance_type    = "${var.node_instance_type}"
    node_count            = "${var.node_asg_desired}"
    node_volume_size      = "${var.node_volume_size}"
    ami_name              = "${data.aws_ami.kops_ami.id}"
    bastion_instance_type = "${var.bastion_instance_type}"
    bastion_count         = "${var.bastion_asg_desired}"
    master_instance_type  = "${var.master_instance_type}"
    master_user_data      = "${data.template_file.master_user_data.0.rendered}"
    node_user_data        = "${data.template_file.node_user_data.rendered}"
    cluster_spec          = "${data.template_file.cluster_spec.rendered}"
    bastions_spec         = "${data.template_file.bastions_spec.rendered}"
    masters_spec          = "${data.template_file.masters_spec.rendered}"
    nodes_spec            = "${data.template_file.nodes_spec.rendered}"
  }

  provisioner "local-exec" {
    command = <<EOF
${path.module}/bin/kops-specs/generate_specs.py \
  --template-path ${path.module}/data/kops \
  --out-path ${path.module}/out \
  --cluster-name ${var.cluster_fqdn} \
  --vpc-id ${var.vpc_id} \
  --state-bucket ${var.kops_s3_bucket_id} \
  --kubernetes-version ${var.kubernetes_version} \
  --dns-zone ${var.route53_zone_id} \
  --zones ${join(",", var.availability_zones)} \
  --network-cidr ${var.vpc_cidr} \
  --node-instance-type ${var.node_instance_type} \
  --node-count ${var.node_asg_desired} \
  --node-volume-size ${var.node_volume_size} \
  --ami-name ${data.aws_ami.kops_ami.id} \
  --bastion-instance-type ${var.bastion_instance_type} \
  --bastion-count ${var.bastion_asg_desired} \
  --master-instance-type ${var.master_instance_type} \
  --public-subnet-zones '${jsonencode(var.vpc_public_subnet_zones)}' \
  --private-subnet-zones '${jsonencode(var.vpc_private_subnet_zones)}' \
  --public-subnet-cidrs '${jsonencode(var.vpc_public_subnet_cidrs)}' \
  --private-subnet-cidrs '${jsonencode(var.vpc_private_subnet_cidrs)}' \
  --nat-gateway-subnets '${jsonencode(var.vpc_nat_gateway_subnets)}'

kops replace -f ${path.module}/out/cluster.yml --state=s3://${var.kops_s3_bucket_id}
kops replace -f ${path.module}/out/bastions.yml --state=s3://${var.kops_s3_bucket_id}
kops replace -f ${path.module}/out/masters.yml --state=s3://${var.kops_s3_bucket_id}
kops replace -f ${path.module}/out/nodes.yml --state=s3://${var.kops_s3_bucket_id}

kops update cluster ${var.cluster_fqdn} --target terraform \
  --state=s3://${var.kops_s3_bucket_id}

kops rolling-update cluster ${var.cluster_fqdn} --state=s3://${var.kops_s3_bucket_id} --yes
EOF
  }
}

resource "null_resource" "delete_tf_files" {
  depends_on = ["null_resource.create_cluster"]

  provisioner "local-exec" {
    command = "rm -rf out"
  }
}

resource "null_resource" "delete_kops_files" {
  depends_on = ["null_resource.create_cluster"]

  provisioner "local-exec" {
    command = "rm -rf ${path.module}/out"
  }
}
