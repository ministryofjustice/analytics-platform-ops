#! /usr/bin/env bash
set -ex

if [ $# -lt 1 ]; then
  echo 1>&2 "usage: $0 ENV_NAME"
  exit 2
fi

ENV_NAME=$1

./create_tf_resources.sh $ENV_NAME
./create_k8s_cluster.sh $ENV_NAME
./install_helm_charts.sh $ENV_NAME
