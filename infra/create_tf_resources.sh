#! /usr/bin/env bash
set -ex

if [ $# -lt 1 ]; then
  echo 1>&2 "usage: $0 ENV_NAME"
  exit 2
fi

ENV_NAME=$1

cd $(dirname $0)
INFRA_DIR=`pwd`

TF_DIR=$INFRA_DIR/terraform
TF_ENV_DIR=$TF_DIR/environments/$ENV_NAME


# Use 'dev' TF environment as template
cp -R $TF_DIR/environments/dev $TF_ENV_DIR
cd $TF_ENV_DIR

# Delete old local terraform configuration
rm -rf .terraform

# Change env name in terraform.tvars
sed -i '.old'  "s/env = \"dev\"/env = \"$ENV_NAME\"/g" terraform.tfvars

# Change env name in terraform backend
sed -i '.old'  "s/dev\/terraform.tfstate/$ENV_NAME\/terraform.tfstate/g" main.tf

# GENERATE new gh_hook_secret secret
# TODO

# Copy shared SAML certificate
cp $TF_DIR/modules/federated_identity/saml/SHARED-auth0-metadata.xml $TF_DIR/modules/federated_identity/saml/$ENV_NAME-auth0-metadata.xml

# Init remote terraform state
terraform init

# Create terraform resources
terraform apply
