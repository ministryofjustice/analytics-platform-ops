#! /usr/bin/env bash
set -ex

if [ $# -lt 1 ]; then
  echo 1>&2 "usage: $0 ENV_NAME"
  exit 2
fi

ENV_NAME=$1

cd $(dirname $0)
INFRA_DIR=`pwd`

# Set helm charts envs paths
HELM_CHARTS_DIR="$INFRA_DIR/../charts"
HELM_CHARTS_CONFIG_DIR="$INFRA_DIR/../chart-env-config"
HELM_CHARTS_CONFIG_ENV_DIR="$HELM_CHARTS_CONFIG_DIR/$ENV_NAME"
HELM_CHARTS_CONFIG_TEMPLATE_DIR="$HELM_CHARTS_CONFIG_DIR/TEMPLATE"


# cd into terraform env dir to use `terraform output ...`
cd $INFRA_DIR/terraform/environments/$ENV_NAME

# Get domain name
DOMAIN_NAME=`terraform output -module cluster_dns dns_zone_domain`

# Be sure we're using the right k8s cluster
kubectl config use-context $DOMAIN_NAME

# Initialise helm (install "tiller", helm server on k8s cluster)
helm init

# Create directory for environent helm charts' values
mkdir $HELM_CHARTS_CONFIG_ENV_DIR

# Install node-exporter helm chart
helm install $HELM_CHARTS_DIR/node-exporter --namespace kube-system --name node-metrics

# Install heapster helm chart
helm install $HELM_CHARTS_DIR/heapster --namespace kube-system --name heapster

# Request SSL certificate
#
# NOTE: This will require approval by clicking on the received emails
SSL_ARN=`aws acm request-certificate request-certificate --domain-name $DOMAIN_NAME | jq --raw-input '.CertificateArn'`

# Render nginx-ingress chart values
ssl_arn=$SSL_ARN \
gucci $HELM_CHARTS_CONFIG_TEMPLATE_DIR/nginx-ingress.yml > $HELM_CHARTS_CONFIG_ENV_DIR/nginx-ingress.yml

# Install nginx-ingress helm chart
helm install $HELM_CHARTS_DIR/nginx-ingress -f $HELM_CHARTS_CONFIG_ENV_DIR/nginx-ingress.yml --namespace kube-system --name cluster-ingress

# Generate kube-dashboard's cookie secret
COOKIE_SECRET=`openssl rand -hex 16`

# Render kube-dashboard chart values
domain=$DOMAIN_NAME \
cookie_secret=$COOKIE_SECRET \
gucci $HELM_CHARTS_CONFIG_TEMPLATE_DIR/kube-dashboard.yml > $HELM_CHARTS_CONFIG_ENV_DIR/kube-dashboard.yml

# Install kube-dashboard helm chart
helm install $HELM_CHARTS_DIR/kube-dashboard -f $HELM_CHARTS_CONFIG_ENV_DIR/kube-dashboard.yml --namespace default --name cluster-dashboard

# cp fluentd chart values
cp $HELM_CHARTS_CONFIG_TEMPLATE_DIR/fluentd.yml $HELM_CHARTS_CONFIG_ENV_DIR/fluentd.yml

# Install fluentd helm chart
helm install $HELM_CHARTS_DIR/fluentd -f $HELM_CHARTS_CONFIG_ENV_DIR/fluentd.yml --namespace kube-system --name cluster-logging

# TODO: Install kibana-auth-proxy helm chart
#    Q: Do we still need this auth proxy????
# NOTE: Current helm chart points to wrong ES

# Render prometheus chart values
domain=$DOMAIN_NAME \
gucci $HELM_CHARTS_CONFIG_TEMPLATE_DIR/prometheus.yml > $HELM_CHARTS_CONFIG_ENV_DIR/prometheus.yml

# Install prometheus helm chart
helm install stable/prometheus -f $HELM_CHARTS_CONFIG_ENV_DIR/prometheus.yml --namespace kube-system --name cluster-metrics

# Render grafana chart values
domain=$DOMAIN_NAME \
gucci $HELM_CHARTS_CONFIG_TEMPLATE_DIR/grafana.yml > $HELM_CHARTS_CONFIG_ENV_DIR/grafana.yml

# Install grafana helm chart
helm install stable/grafana -f $HELM_CHARTS_CONFIG_ENV_DIR/grafana.yml --namespace kube-system --name cluster-monitoring

# Render init-platform chart values
domain=$DOMAIN_NAME \
gucci $HELM_CHARTS_CONFIG_TEMPLATE_DIR/init-platform.yml > $HELM_CHARTS_CONFIG_ENV_DIR/init-platform.yml

# Install init-platform helm chart
helm install $HELM_CHARTS_DIR/init-platform -f $HELM_CHARTS_CONFIG_ENV_DIR/init-platform.yml --namespace default --name init-platform

# Render init-user chart values
domain=$DOMAIN_NAME \
gucci $HELM_CHARTS_CONFIG_TEMPLATE_DIR/init-user.yml > $HELM_CHARTS_CONFIG_ENV_DIR/init-user.yml

# Render jenkins chart values
domain=$DOMAIN_NAME \
gucci $HELM_CHARTS_CONFIG_TEMPLATE_DIR/jenkins.yml > $HELM_CHARTS_CONFIG_ENV_DIR/jenkins.yml

# Install jenkins helm chart
helm install stable/jenkins -f $HELM_CHARTS_CONFIG_ENV_DIR/jenkins.yml --namespace default --name control-panel
