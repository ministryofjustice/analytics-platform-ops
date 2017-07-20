#! /usr/bin/env bash
set -ex

if [ $# -lt 1 ]; then
  echo 1>&2 "usage: $0 ENV_NAME"
  exit 2
fi

ENV_NAME=$1

cd $(dirname $0)
INFRA_DIR=`pwd`

echo "WARNING: This is going to destroy the '$ENV_NAME' environment. This can't be reverted."
sleep 10


# cd into terraform env dir to use `terraform output ...`
cd $INFRA_DIR/terraform/environments/$ENV_NAME

# Get cluster name
KOPS_CLUSTER_NAME=`terraform output -module cluster_dns dns_zone_domain`

# Delete k8s cluster
#
# NOTE: This may fail after while. Retry may work.
#       https://github.com/kubernetes/kops/issues/383
kops delete cluster --name=$KOPS_CLUSTER_NAME --yes

# Delete terraform resources
#
# NOTE: This may fail if there are resources not created by Terraform.
#       e.g. subnets created by KOPS within the VPC (created by Terraform)
terraform destroy -force
