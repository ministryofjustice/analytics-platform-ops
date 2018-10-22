#!/usr/bin/env bash

if [ $# -lt 4 ]; then
  echo 1>&2 "usage:"
  # You need to be in the platform directory for the 'terraform output' commands to work
  echo 1>&2 "  cd ../../../infra/terraform/platform"
  echo 1>&2 "  ../../kops/configure.sh $KOPS_STATE_STORE $ENVNAME $ENV_DOMAIN $KUBECTL_OIDC_CLIENT_ID"
  exit 2
fi

set -ex

KOPS_STATE_STORE=$1
ENVNAME=$2
ENV_DOMAIN=$3
KUBECTL_OIDC_CLIENT_ID=$4

yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.configBase $KOPS_STATE_STORE/$ENV_DOMAIN
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.kubeAPIServer.oidcClientID $KUBECTL_OIDC_CLIENT_ID
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.kubeAPIServer.oidcGroupsClaim https://api.$ENV_DOMAIN/claims/groups
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.kubeAPIServer.oidcIssuerURL `terraform output oidc_provider_url`
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml metadata.name $ENV_DOMAIN
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.masterInternalName api.internal.$ENV_DOMAIN
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.masterPublicName api.$ENV_DOMAIN
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.topology.bastion.bastionPublicName bastion.$ENV_DOMAIN
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.dnsZone `terraform output -module=cluster_dns dns_zone_id`
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.networkID `terraform output -module=aws_vpc vpc_id`
terraform output -module=aws_vpc -json private_subnets > /tmp/private_subnets
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.subnets[0].id `jq '.value|to_entries|sort_by(.value)[0].key' /tmp/private_subnets`
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.subnets[1].id `jq '.value|to_entries|sort_by(.value)[1].key' /tmp/private_subnets`
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.subnets[2].id `jq '.value|to_entries|sort_by(.value)[2].key' /tmp/private_subnets`
terraform output -module=aws_vpc -json dmz_subnets > /tmp/dmz_subnets
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.subnets[3].id `jq '.value|to_entries|sort_by(.value)[0].key' /tmp/dmz_subnets`
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.subnets[4].id `jq '.value|to_entries|sort_by(.value)[1].key' /tmp/dmz_subnets`
yq w -i ../../../infra/kops/clusters/$ENVNAME/cluster.yml spec.subnets[5].id `jq '.value|to_entries|sort_by(.value)[2].key' /tmp/dmz_subnets`
yq w -i ../../../infra/kops/clusters/$ENVNAME/masters.yml -d'*' 'metadata.labels[kops.k8s.io/cluster]' $ENV_DOMAIN
yq w -i ../../../infra/kops/clusters/$ENVNAME/masters.yml -d'*' spec.additionalSecurityGroups[0] `terraform output -module=aws_vpc extra_master_sg_id`
yq w -i ../../../infra/kops/clusters/$ENVNAME/nodes.yml 'metadata.labels[kops.k8s.io/cluster]' $ENV_DOMAIN
yq w -i ../../../infra/kops/clusters/$ENVNAME/nodes.yml -d'*' spec.additionalSecurityGroups[0] `terraform output -module=aws_vpc extra_node_sg_id`
yq w -i ../../../infra/kops/clusters/$ENVNAME/bastions.yml 'metadata.labels[kops.k8s.io/cluster]' $ENV_DOMAIN
yq w -i ../../../infra/kops/clusters/$ENVNAME/bastions.yml -d'*' spec.additionalSecurityGroups[0] `terraform output -module=aws_vpc extra_bastion_sg_id`
