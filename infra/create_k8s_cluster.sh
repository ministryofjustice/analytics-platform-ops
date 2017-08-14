#! /usr/bin/env bash
set -ex

if [ $# -lt 1 ]; then
  echo 1>&2 "usage: $0 ENV_NAME"
  exit 2
fi

ENV_NAME=$1

cd $(dirname $0)
INFRA_DIR=`pwd`

# cd into terraform env dir to use `terraform output ...`
cd $INFRA_DIR/terraform/environments/$ENV_NAME

KOPS_DIR=$INFRA_DIR/kops
KOPS_CLUSTER_TEMPLATE_DIR=$KOPS_DIR/TEMPLATE_CLUSTER
KOPS_CLUSTER_DIR=$KOPS_DIR/clusters/$ENV_NAME
KOPS_STATE_STORE=s3://`grep "terraform_bucket_name =" terraform.tfvars | cut -d\" -f 2 | sed -e 's/terraform/kops/'`

# Install command to render templates (Requires Go)
go get github.com/noqcks/gucci

# Create cluster dir
mkdir $KOPS_CLUSTER_DIR

# Get cluster name
KOPS_CLUSTER_NAME=`terraform output -module cluster_dns dns_zone_domain`

# Get EXTRA_MASTER_SECURITY_GROUP_ID
EXTRA_MASTER_SECURITY_GROUP_ID=`terraform output -module=aws_vpc extra_master_sg_id`

# Get EXTRA_NODE_SECURITY_GROUP_ID
EXTRA_NODE_SECURITY_GROUP_ID=`terraform output -module=aws_vpc extra_node_sg_id`

# Get DNS_ZONE_ID
DNS_ZONE_ID=`terraform output -module=cluster_dns dns_zone_id`

# Get VPC_ID
VPC_ID=`terraform output -module=aws_vpc vpc_id`

# Get PRIVATE_SUBNETS, e.g. `subnet-1=eu-west-1a,subnet-2=eu-west-1b`
PRIVATE_SUBNETS=`terraform output -json -module=aws_vpc private_subnets | jq --raw-output '.value | to_entries | map(.key + "=" + .value) | join(",")'`

# Get DMZ_SUBNETS, e.g. `subnet-1=eu-west-1a,subnet-2=eu-west-1b`
DMZ_SUBNETS=`terraform output --json -module=aws_vpc dmz_subnets | jq --raw-output '.value | to_entries | map(.key + "=" + .value) | join(",")'`

# Render KOPS resource templates: bastions.yml
cluster_name=$KOPS_CLUSTER_NAME \
gucci $KOPS_CLUSTER_TEMPLATE_DIR/bastions.yml > $KOPS_CLUSTER_DIR/bastions.yml

# Render KOPS resource templates: masters.yml
cluster_name=$KOPS_CLUSTER_NAME \
extra_master_security_group_id=$EXTRA_MASTER_SECURITY_GROUP_ID \
gucci $KOPS_CLUSTER_TEMPLATE_DIR/masters.yml > $KOPS_CLUSTER_DIR/masters.yml

# Render KOPS resource templates: nodes.yml
cluster_name=$KOPS_CLUSTER_NAME \
nodes_instance_size=$K8S_NODES_INSTANCE_SIZE \
extra_node_security_group_id=$EXTRA_NODE_SECURITY_GROUP_ID \
gucci $KOPS_CLUSTER_TEMPLATE_DIR/nodes.yml > $KOPS_CLUSTER_DIR/nodes.yml

# Render KOPS resource templates: cluster.yml
cluster_name=$KOPS_CLUSTER_NAME \
vpc_id=$VPC_ID \
dns_zone_id=$DNS_ZONE_ID \
private_subnets=$PRIVATE_SUBNETS \
dmz_subnets=$DMZ_SUBNETS \
kops_state_store=$KOPS_STATE_STORE \
gucci $KOPS_CLUSTER_TEMPLATE_DIR/cluster.yml > $KOPS_CLUSTER_DIR/cluster.yml

# Plan KOPS cluster creation
kops create -f $KOPS_CLUSTER_DIR/cluster.yml
kops create -f $KOPS_CLUSTER_DIR/bastions.yml
kops create -f $KOPS_CLUSTER_DIR/masters.yml
kops create -f $KOPS_CLUSTER_DIR/nodes.yml

# Set path to cluster public key
CLUSTER_SSH_KEY_PATH=~/.ssh/id_rsa.$KOPS_CLUSTER_NAME

# Create cluster SSH key
ssh-keygen -t rsa -b 4096 -P "" -f $CLUSTER_SSH_KEY_PATH -C $KOPS_CLUSTER_NAME

# Add generated SSH (public!) key to cluster
kops create secret --name $KOPS_CLUSTER_NAME sshpublickey admin -i $CLUSTER_SSH_KEY_PATH.pub

# Create k8s cluter: This will create the EC2 instances, etc...
#
# NOTE: This returns quite quickly but the EC2 instances' initialisation
#       takes some time (~5 minutes for a normal 3 nodes cluster)
kops update cluster $KOPS_CLUSTER_NAME --yes
