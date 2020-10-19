#!/usr/bin/env bash
set -ex

if [ $# -lt 1 ]; then
  echo 1>&2 "usage: $0 ENV_NAME"
  exit 2
fi

ENV_NAME=$1

cd "$(dirname "${0}")"
INFRA_DIR=$(pwd)

# Set helm charts envs paths
HELM_CHARTS_CONFIG_DIR="$INFRA_DIR/../chart-env-config"
HELM_CHARTS_CONFIG_ENV_DIR="$HELM_CHARTS_CONFIG_DIR/$ENV_NAME"
HELM_CHARTS_CONFIG_TEMPLATE_DIR="$HELM_CHARTS_CONFIG_DIR/TEMPLATE"


# cd into terraform env dir to use `terraform output ...`
cd "${INFRA_DIR}/terraform/environments/${ENV_NAME}"
DOMAIN_NAME=$(terraform output -module cluster_dns dns_zone_domain)

# Be sure we're using the right k8s cluster
kubectl config use-context "${DOMAIN_NAME}"

# Initialise helm (install "tiller", helm server on k8s cluster)
helm init
helm repo add mojanalytics http://moj-analytics-helm-repo.s3-website-eu-west-1.amazonaws.com
helm repo update

# Create directory for environent helm charts' values
mkdir "${HELM_CHARTS_CONFIG_ENV_DIR}"

# Install node-exporter helm chart
helm install mojanalytics/node-exporter --namespace kube-system --name node-metrics

# Install metrics-server helm chart
helm install metrics-server stable/metrics-server --namespace default --name metrics-server -f "${HELM_CHARTS_CONFIG_ENV_DIR}/metrics-server.yaml"

# Request SSL certificate
#
# NOTE: This will require approval by clicking on the received emails
SSL_ARN=$(aws acm request-certificate request-certificate --domain-name "${DOMAIN_NAME}" | jq --raw-input '.CertificateArn')

# Render nginx-ingress chart values
ssl_arn=$SSL_ARN \
gucci "${HELM_CHARTS_CONFIG_TEMPLATE_DIR}/nginx-ingress.yml" > "${HELM_CHARTS_CONFIG_ENV_DIR}/nginx-ingress.yml"

# Install nginx-ingress helm chart
helm install mojanalytics/nginx-ingress -f "${HELM_CHARTS_CONFIG_ENV_DIR}/nginx-ingress.yml" --namespace kube-system --name cluster-ingress

# Generate kube-dashboard's cookie secret
COOKIE_SECRET=$(openssl rand -hex 16)

# Render kube-dashboard chart values
domain=$DOMAIN_NAME \
cookie_secret=$COOKIE_SECRET \
gucci "${HELM_CHARTS_CONFIG_TEMPLATE_DIR}/kube-dashboard.yml" > "${HELM_CHARTS_CONFIG_ENV_DIR}/kube-dashboard.yml"

# Install kube-dashboard helm chart
helm install mojanalytics/kube-dashboard -f "${HELM_CHARTS_CONFIG_ENV_DIR}/kube-dashboard.yml "--namespace default --name cluster-dashboard

# Render fluentd chart values
env_name=${ENV_NAME} \
gucci "${HELM_CHARTS_CONFIG_TEMPLATE_DIR}/fluentd.yml" > "${HELM_CHARTS_CONFIG_ENV_DIR}/fluentd.yml"

# Install fluentd helm chart
helm install mojanalytics/fluentd -f "${HELM_CHARTS_CONFIG_ENV_DIR}/fluentd.yml" --namespace kube-system --name cluster-logging

# TODO: Install kibana-auth-proxy helm chart
#    Q: Do we still need this auth proxy????
# NOTE: Current helm chart points to wrong ES

# Render prometheus chart values
domain=${DOMAIN_NAME} \
gucci "${HELM_CHARTS_CONFIG_TEMPLATE_DIR}/prometheus.yml" > "${HELM_CHARTS_CONFIG_ENV_DIR}/prometheus.yml"

# Install prometheus helm chart
helm install stable/prometheus -f "${HELM_CHARTS_CONFIG_ENV_DIR}/prometheus.yml" --namespace kube-system --name cluster-metrics

# Render grafana chart values
domain=${DOMAIN_NAME} \
gucci "${HELM_CHARTS_CONFIG_TEMPLATE_DIR}/grafana.yml" > "${HELM_CHARTS_CONFIG_ENV_DIR}/grafana.yml"

# Install grafana helm chart
helm install stable/grafana -f "${HELM_CHARTS_CONFIG_ENV_DIR}/grafana.yml" --namespace kube-system --name cluster-monitoring

# Render init-platform chart values
domain=${DOMAIN_NAME} \
gucci "$HELM_CHARTS_CONFIG_TEMPLATE_DIR/init-platform.yml" > "$HELM_CHARTS_CONFIG_ENV_DIR/init-platform.yml"

# Install init-platform helm chart
helm install mojanalytics/init-platform -f "$HELM_CHARTS_CONFIG_ENV_DIR/init-platform.yml" --namespace default --name init-platform

# Render init-user chart values
domain=${DOMAIN_NAME} \
gucci "${HELM_CHARTS_CONFIG_TEMPLATE_DIR}/init-user".yml > "${HELM_CHARTS_CONFIG_ENV_DIR}/init-user.yml"

# Render jenkins chart values
domain=${DOMAIN_NAME} \
gucci "${HELM_CHARTS_CONFIG_TEMPLATE_DIR}/jenkins.yml" > "${HELM_CHARTS_CONFIG_ENV_DIR}/jenkins.yml"

# Install jenkins helm chart
helm install stable/jenkins -f "${HELM_CHARTS_CONFIG_ENV_DIR}/jenkins.yml" --namespace default --name control-panel

# cp kube2iam chart values
cp "${HELM_CHARTS_CONFIG_TEMPLATE_DIR}/kube2iam.yml" "${HELM_CHARTS_CONFIG_ENV_DIR}/kube2iam.yml"

# Install kube2iam
helm install mojanalytics/kube2iam -f "${HELM_CHARTS_CONFIG_ENV_DIR}/kube2iam.yml" --namespace default --name kube2iam
