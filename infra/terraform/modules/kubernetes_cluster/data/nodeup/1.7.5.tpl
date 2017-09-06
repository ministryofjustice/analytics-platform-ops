echo "== nodeup node config starting =="
ensure-install-dir

cat > kube_env.yaml << __EOF_KUBE_ENV
Assets:
- 91ed0f6eb45971d56f8c26acb8dfa8e593282012@https://storage.googleapis.com/kubernetes-release/release/v1.7.5/bin/linux/amd64/kubelet
- bee713b4c1e024ffc9281440b3d19c1576e5932b@https://storage.googleapis.com/kubernetes-release/release/v1.7.5/bin/linux/amd64/kubectl
- 1d9788b0f5420e1a219aad2cb8681823fc515e7c@https://storage.googleapis.com/kubernetes-release/network-plugins/cni-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz
- 5d95d64d7134f202ba60b1fa14adaff138905d15@https://kubeupv2.s3.amazonaws.com/kops/1.7.0/linux/amd64/utils.tar.gz
ClusterName: ${cluster_fqdn}
ConfigBase: s3://${kops_s3_bucket_id}/${cluster_fqdn}
InstanceGroupName: ${autoscaling_group_name}
Tags:
- _automatic_upgrades
- _aws
${kubernetes_master_tag}
- _networking_cni
channels:
- s3://${kops_s3_bucket_id}/${cluster_fqdn}/addons/bootstrap-channel.yaml
protokubeImage:
  hash: 5bd97a02f0793d1906e9f446c548ececf1444737
  name: protokube:1.7.0
  source: https://kubeupv2.s3.amazonaws.com/kops/1.7.0/images/protokube.tar.gz

__EOF_KUBE_ENV

download-release
echo "== nodeup node config done =="
