#!/usr/bin/env bash

# Add the `host` label to all RStudio/JupyterLab resources


set -e


if [[ -z "${APP}" ]]; then
  echo "Please specify APP. It can be 'rstudio' or 'jupyter-lab' at the moment."
  exit 1
fi


NAMESPACES=`kubectl get ns | grep user- | cut -f1 -d' '`
for NAMESPACE in $NAMESPACES; do
  echo "NAMESPACE='$NAMESPACE'"

  # Get host from Ingress resource
  host=`kubectl --namespace=${NAMESPACE} --selector="app=${APP}" get ingress --ignore-not-found=true -o jsonpath='{.items[0].spec.rules[0].host}'`
  if [[ -z $host ]]; then
    echo "${NAMESPACE}: No ingress found in namespace. Skipping."
    continue
  fi

  echo "${NAMESPACE}: Adding host='$host' to ${APP}..."

  # Label Ingress
  kubectl --namespace=${NAMESPACE} --selector="app=${APP}" label ingress host=${host} --overwrite=true && echo "${NAMESPACE}: Ingress labelled"

  # Label Secret
  kubectl --namespace=${NAMESPACE} --selector="app=${APP}" label secret host=${host} --overwrite=true && echo "${NAMESPACE}: Secret labelled"

  # Label ConfigMap
  kubectl --namespace=${NAMESPACE} --selector="app=${APP}" label configmap host=${host} --overwrite=true && echo "${NAMESPACE}: ConfigMap labelled"

  # Label Service
  kubectl --namespace=${NAMESPACE} --selector="app=${APP}" label service host=${host} --overwrite=true && echo "${NAMESPACE}: Service labelled"

  # Label Deployment
  kubectl --namespace=${NAMESPACE} --selector="app=${APP}" label deployment host=${host} --overwrite=true && echo "${NAMESPACE}: Deployment labelled"

  # Label Job
  kubectl --namespace=${NAMESPACE} --selector="app=${APP}" label job host=${host} --overwrite=true && echo "${NAMESPACE}: Job labelled"

  # Make sure Deployment's pods also get the host label
  deployment=`kubectl --namespace=${NAMESPACE} --selector="app=${APP}" get deployment --ignore-not-found=true -o jsonpath='{.items[0].metadata.name}'`
  if [[ ! -z $deployment ]]; then
    echo "${NAMESPACE}: DEPLOYMENT='$deployment'"
    kubectl --namespace=${NAMESPACE} patch deployment ${deployment} --type='json' -p="[{\"op\": \"add\", \"path\": \"/spec/template/metadata/labels/host\", \"value\": \"$host\"}]" && echo "${NAMESPACE}: Deployment patched"
  fi

  # Make sure Job's pods also get the host label
  job=`kubectl --namespace=${NAMESPACE} --selector="app=${APP}" get job --ignore-not-found=true -o jsonpath='{.items[0].metadata.name}'`
  if [[ ! -z $job ]]; then
    echo "${NAMESPACE}: JOB='$job'"
    kubectl --namespace=${NAMESPACE} patch job ${job} --type='json' -p="[{\"op\": \"add\", \"path\": \"/spec/template/metadata/labels/host\", \"value\": \"$host\"}]" && echo "${NAMESPACE}: Job patched"
  fi

done
