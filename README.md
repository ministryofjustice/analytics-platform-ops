# MOJ Analytics Platform Ops and Infrastructure

[Kubernetes][kubernetes]-based data analysis platform, using [Terraform][terraform], [Kops][kops] and [Helm][helm] charts.

Contact robin.linacre@digital.justice.gov.uk if you're in government and interested in talking to us about analytics platforms.

## Directory structure

* `infra`
[Terraform][terraform] resources for AWS infrastructure and [Kops][kops] resources for Kubernetes clusters
* `jenkinsfiles`
[Jenkins][jenkins] scripts for deployment and management tasks
* `charts`
[Helm][helm] charts for platform software and platform/user setup
* `chart-env-config`
Per-environment values and configuration for [Helm][helm] charts

## Prerequisites
Install:

  * [Terraform][terraform]
  * [Kops][kops]
  * [git-crypt][gitcrypt]

## Infrastructure Overview

A combination of [Terraform](https://www.terraform.io) and [Kops](https://github.com/kubernetes/kops) are used to create and manage AWS environments and Kubernetes clusters.

**[Terraform][terraform]** is used to provision the base AWS environment (VPC, NAT Gateways, subnets etc.) and non-Kubernetes, off-cluster resources such as S3, EFS, IAM policies, Lambda functions, etc).

**[Kops][kops]** is used to provision and manage Kubernetes clusters (EC2 instances, ELBs, Security Groups, AutoScaling Groups, Route53 DNS entries, etc).

**[Helm][helm]** is used to manage installation and updates of all Kubernetes resources, including end-user software.

This project and repository is designed to manage multiple environments (staging, test, production, etc), so contains some global elements that are used by all environments, namely S3 buckets for Terraform and Kops, and a Route53 DNS zone.

Because both Terraform and Kops create AWS resources in two different phases, the order of execution during environment creation, and separation of responsibilities between the two is important. The current high-level execution plan is:

1. `terraform apply` for 'global' resources shared across all environments. This currently consists of root DNS records, and S3 buckets for Terraform and Kops state storage. These resources only needed to be created once for all environments.
2. `terraform apply` for the specific environment. This creates the VPC, subnets, gateways etc. for the Kubernetes cluster, a Route53 hosted zone for the environment, S3 data buckets for the platform, and EFS file storage.
3. `kops create|update cluster` for the Kubernetes cluster itself. This creates EC2 instances, AutoScaling groups, Security Groups, ELBs, etc. within the Terraform-created VPC.

## Secrets and git-crypt

Terraform `terraform.tfvars` files and env-specific [Helm][helm] values files contain sensitive information, so are encrypted using `git-crypt`. To work with this repository you must ask a repo member or admin to add your GPG key.

## Kubernetes resource management

All [Kubernetes][kubernetes] resources are managed as [Helm][helm] charts, the Kubernetes package manager. Analytics-specific charts are currently stored in the `charts/` directory, and chart values for each environment are stored in the `chart-env-config/` directory.

## Creating global AWS resources, and preparing Terraform remote state

**You must have valid AWS credentials in [`~/.aws/credentials`](http://docs.aws.amazon.com/amazonswf/latest/awsrbflowguide/set-up-creds.html)**

Global AWS resources (DNS and S3 buckets) only need to be created once, and are then used by all environments created subsequently. These resources have likely already been created, in which case you can skip ahead to remote state setup, but if you are starting from a clean slate:

  1. `$ cd infra/terraform/global`
  2. `$ terraform init` - set up remote state backend and pull modules
  3. `$ terraform plan` - check that Terraform plans to create two S3 buckets (Terraform and Kops state) and a root DNS zone in Route53.
  4. `$ terraform apply` to create resources


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


### Working with an existing environment
You must initialize your local Terraform environment to work with remote state stored in the S3 bucket created above before continuing.

1. `$ cd infra/terraform/environments/YOUR_ENV`
2. `$ terraform init` - initialize remote state and pull required modules

### Creating AWS resources, or applying changes to existing environment

Once remote Terraform state has been configured you can now apply changes to existing environments, or create a new environment:

1. `$ cd infra/terraform/environments/YOUR_ENV`
2. `$ terraform plan` - this will preview the changes Terraform plans to make
3. `$ terraform apply` - applies the above changes

Once complete your base AWS resources should be in place


### Create Kubernetes cluster

1. Install [kubectl](https://kubernetes.io/docs/user-guide/prereqs/) and [Kops][kops] if you haven't already
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

4. Set Kops state store environment variable:
  `$ export KOPS_STATE_STORE=s3://$STATE_BUCKET_NAME`
4. Plan Kops cluster resource creation:

	```
	$ kops create -f cluster.yml
	$ kops create -f bastions.yml
	$ kops create -f masters.yml
	$ kops create -f nodes.yml
	```
5. Create SSH keys: `$ ssh-keygen -t rsa -b 4096`
6. Add key to Kops cluster:
  `$ kops create secret --name CLUSTER_NAME sshpublickey admin -i PATH_TO_PUBLIC_KEY`
  Where `$CLUSTER_NAME` matches the name provided in YAML files
7. Plan and create cluster:

  ```
  $ kops update cluster $CLUSTER_NAME
  $ kops update cluster $CLUSTER_NAME --yes
  ```


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

[terraform]: https://www.terraform.io
[kops]: https://github.com/kubernetes/kops
[helm]: https://github.com/kubernetes/helm/
[kubernetes]: https://kubernetes.io
[jenkins]: https://jenkins.io
[gitcrypt]: https://www.agwa.name/projects/git-crypt/
