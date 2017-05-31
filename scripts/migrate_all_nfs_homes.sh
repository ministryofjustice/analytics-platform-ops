#!/usr/bin/env bash

env=$(kubectl config current-context | cut -f 1 -d .)

# Update top-level NFS homes PersistentVolume
helm upgrade init-platform charts/init-platform --reuse-values

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
