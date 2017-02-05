#!/bin/bash
set -ex

if [ $# -lt 2 ]; then
  echo 1>&2 "$0: Arguments: KOPS_STATE_STORE_BUCKET SSH_PUBLIC_KEY_PATH"
  exit 2
fi

KOPS_STATE_STORE=s3://${1}
SSH_PUBLIC_KEY=${2}

KUBERNETES_VERSION=1.5.1
CHANNEL=alpha
NETWORKING=calico
MASTER_SIZE=t2.medium
NODE_COUNT=3
NODE_SIZE=m4.xlarge

CLUSTER_NAME=$(terraform output dns_zone_domain)
DNS_ZONE=$(terraform output dns_zone_id)
NETWORK_CIDR=$(terraform output --module=aws_vpc cidr)
VPC_ID=$(terraform output --module=aws_vpc vpc_id)
MASTER_ZONES=$(terraform output --module=aws_vpc availability_zones)
ZONES=$(terraform output --module=aws_vpc availability_zones)
NODE_SECURITY_GROUPS=$(terraform output --module=aws_vpc extra_node_sg_id)


kops create cluster \
    --bastion \
    --name=$CLUSTER_NAME \
    --associate-public-ip=false \
    --topology=private \
    --cloud=aws \
    --dns-zone=$DNS_ZONE \
    --master-size=$MASTER_SIZE \
    --master-zones=$MASTER_ZONES \
    --networking=$NETWORKING \
    --network-cidr=$NETWORK_CIDR \
    --node-security-groups=$NODE_SECURITY_GROUPS \
    --node-count=$NODE_COUNT \
    --node-size=$NODE_SIZE \
    --channel=$CHANNEL \
    --ssh-public-key=$SSH_PUBLIC_KEY \
    --zones=$ZONES \
    --state=$KOPS_STATE_STORE \
    --vpc=$VPC_ID
