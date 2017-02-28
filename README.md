# MOJ Analytics Platform Ops and Infrastructure

A collection of Terraform resources for AWS infrastructure, and Kubernetes resources for the Kubernetes-based Analytics platform.

## Directory structure

* `infra`
Terraform resources for AWS infrastructure and Kops resources for Kubernetes clusters
* `jenkinsfiles`
Jenkins scripts for deployment and management tasks
* `k8s-resources`
Kubernetes resources that can be deployed as-is with `kubectl apply`
* `k8s-templates`
Templated Kubernetes resources that require variable interpolation before deployment. These templates use Go-style `{{.Variables}}`, although currently Jenkinsfiles interpolate variables using `sed` rather than Go.

## Infrastructure Overview

A combination of [Terraform](https://www.terraform.io) and [Kops](https://github.com/kubernetes/kops) are used to create and manage AWS environments and Kubernetes clusters.

**Kops** is used to provision and manage Kubernetes clusters (EC2 instances, ELBs, Security Groups, AutoScaling Groups, Route53 DNS entries, etc).

**Terraform** is used to provision non-Kubernetes/off-cluster resources (VPC, NAT Gateways, RDS, S3, EFS, IAM, etc).

Because both Terraform and Kops create AWS resources, and in two different phases, the order of execution during environment creation, and separation of responsibilities between the two is important. The current high-level execution plan is:

1. `terraform apply` for 'global' resources shared across all environments. This currently consists of root DNS records, and S3 buckets for Terraform and Kops state storage. These resources only needed to be created once for all environments.
2. `terraform apply` for the specific environment. This creates the VPC, subnets, gateways etc. for non-cluster resources (RDS etc.), env-specific DNS records, S3 data buckets for the platform, and EFS file storage.
3. `kops create|update cluster` for the Kubernetes cluster itself. This creates EC2 instances, AutoScaling groups, Security Groups, ELBs, etc. within the Terraform-created VPC.

**Both Kops and Terraform require valid AWS credentials in [`~/.aws/credentials`](http://docs.aws.amazon.com/amazonswf/latest/awsrbflowguide/set-up-creds.html)**

## Secrets and git-crypt

Terraform `terraform.tfvars` files and some Kubernetes resources (notably ingress rules) contain sensitive information, so are encrypted using `git-crypt`. To work with this repository you must ask a repo member or admin to add your GPG key.

## Managing global AWS resources, and preparing Terraform remote state

The global AWS resources (DNS and S3 buckets) will almost certainly already be in place - if not, ask a repo admin. However, you must initialize Terraform's remote state so that per-environment Terraform resources can reference it. To initialize remote state in your working repository:

1. `$ cd infra/terraform/global` - (you must cd to this directory)
2. `$ ./init.sh`

Initialization is only required once per local checkout.


## Creating/updating environments with Terraform

### Defining new environment
1. Copy example Terraform resources from `infra/terraform/environments/example` to `infra/terraform/environments/YOUR_ENV`
2. Edit values in `infra/terraform/environments/YOUR_ENV/terraform.tfvars`:

| Variable  | Value |
| ------------- | ------------- |
| `env`  | Environment name, e.g. `dev`, `test`  |
| `domain`  | Base domain name for platform, e.g. `dev.example.com`. This must be a subdomain of a domain already present in Route53 (e.g. `example.com`), and all services will be created under this subdomain (e.g. `grafana.dev.example.com`)  |
| `region`  | AWS region. This must be a region that supports all AWS services created in `infra/terraform/modules`, e.g. `eu-west-1`  |
| `terraform_bucket_name`  | S3 bucket name for Terraform state storage, as created by Terraform `global` resources |
| `terraform_base_state_file`  | Path for Terraform state file for global/base resources created in `infra/terraform/global`, (e.g. `base/terraform.tfstate`)  |
| `vpc_cidr`  | IP range for cluster, e.g. `192.168.0.0/16`  |
| `availability_zones`  | AWS availability zones, e.g. `eu-west-1a, eu-west-1b, eu-west-1c`  |

### Initialize Terraform remote state
1. `$ cd infra/terraform/environments/YOUR_ENV`
2. ```
   terraform remote config \
    -backend=s3 \
    -backend-config="bucket=$BUCKET_NAME" \
    -backend-config="key=$ENV_NAME/terraform.tfstate" \
    -backend-config="region=$AWS_REGION```

`$BUCKET_NAME` and `$AWS_REGION` must match the values provided in `terraform.tfvars`; `$ENV_NAME` should match your environment name.

### Creating AWS resources, or applying changes to existing environment

1. `$ terraform plan` - this will preview the changes Terraform plans to make
2. `$ terraform apply` - applies the above changes

Once complete your AWS resources should be in place


### Create Kubernetes cluster

1. Install [kubectl](https://kubernetes.io/docs/user-guide/prereqs/) and [Kops](https://github.com/kubernetes/kops) if you haven't already
2. `$ cp -R infra/kops/example_cluster infra/kops/clusters/YOUR_ENV`
3. `$ cd infra/kops/clusters/YOUR_ENV`
4. Replace placeholders in all YAML files for your cluster with appropriate Terraform output values:

| Placeholder  | Terraform output value |
| ------------- | ------------- |
| `CLUSTER_NAME`  | (Not from Terraform) - base domain name - must match value in `terraform.tfvars`, e.g. `dev.example.com` |
| `STATE_BUCKET`  | (Not from Terraform) - Terraform state bucket - must match value in `terraform.tfvars`, e.g. `terraform.bucket.name` |
| `DNS_ZONE_ID`  | `$ terraform output -module=cluster_dns dns_zone_id` |
| `VPC_ID`  | `$ terraform output -module=aws_vpc vpc_id` |
| `PRIVATE_SUBNET_ID`  | Each subnet ID from `$ terraform output -module=aws_vpc private_subnets` - zones in `cluster.yml` and terraform output must match |
| `DMZ_SUBNET_ID`  | Each subnet ID from `$ terraform output -module=aws_vpc dmz_subnets` - zones in `cluster.yml` and terraform output must match |
| `EXTRA_MASTER_SECURITY_GROUP_ID`  | `$ terraform output -module=aws_vpc extra_master_sg_id` |
| `EXTRA_NODE_SECURITY_GROUP_ID`  | `$ terraform output -module=aws_vpc extra_node_sg_id` |

4. Plan Kops cluster resource creation:
  ```
  $ kops create -f cluster.yml
  $ kops create -f bastions.yml
  $ kops create -f masters.yml
  $ kops create -f nodes.yml
  ```
5. Plan overall cluster creation:
  `$ kops create cluster $CLUSTER_NAME` - where `$CLUSTER_NAME` matches the name provided in YAML files
6. Execute cluster creation:
  `$ kops create cluster $CLUSTER_NAME --yes`


### Verify cluster creation
1. `$ kubectl cluster-info`

If kubectl is unable to connect, the cluster is still starting, so wait a few minutes and try again; Terraform also creates new DNS entries, so you may need to flush your DNS cache. Once `cluster-info` returns Kubernetes master and KubeDNS your cluster is ready.

### Modifying AWS and cluster post-creation
Once all of the above has been carried out, both Terraform and Kops state buckets will be populated, and your local directory will be configured to push/pull from those buckets, so changes can be made without further configuration.

* To make changes to AWS resources, edit or add Terraform `.tf` files, then:
  * `$ terraform plan`
  * `$ terraform apply`
* To make changes to the cluster, edit Kops cluster specs in place, as unfortunately YAML files can not be passed to the `edit` command. You should however strive to keep your local YAML files in sync with Kops remote files, so that environments can be easily recreated in the future:
  * `$ kops edit cluster $CLUSTER_NAME`
  * Make changes to the cluster spec and save
  * Apply changes: `$ kops update cluster $CLUSTER_NAME --yes`

