#!/usr/bin/env bash

env=$(kubectl config current-context | cut -f 1 -d .)

# Replace top-level NFS homes PersistentVolume
kubectl delete pv nfs-homes
helm upgrade init-platform charts/init-platform \
    --reuse-values \
    -f chart-env-config/$env/init-platform.yml

for user in $(helm list init-user-+ -q | cut -d - -f3); do
    # Jobs, PersistentVolumes and PersistentVolumeClaims all have immutable
    # fields, so they need to be deleted before performing the Helm upgrade
    kubectl delete job create-user-home-$user
    kubectl delete pv nfs-home-$user
    kubectl delete pvc nfs-home -n user-$user

    helm upgrade init-user-$user charts/init-user \
        --reuse-values \
        -f chart-env-config/$env/init-user.yml
done
