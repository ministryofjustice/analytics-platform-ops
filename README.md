# MOJ Analytics Platform Ops and Infrastructure

A collection of Terraform resources for AWS infrastructure, and Kubernetes resources for the Kubernetes-based Analytics platform.

## Directory structure

* `docker`  
Dockerfiles and code for deployable containers - due to be removed from this repository
* `infra`  
Terraform resources for AWS infrastructure
* `jenkinsfiles`  
Jenkins scripts for deployment and management tasks
* `k8s-resources`  
Kubernetes resources that can be deployed as-is with `kubectl apply`
* `k8s-templates`  
Templated Kubernetes resources that require variable interpolation before deployment. These templates use Go-style `{{.Variables}}`, although currently Jenkinsfiles interpolate variables using `sed` rather than Go.

## Infrastructure Overview

A combination of [Terraform](https://www.terraform.io) and [Kops](https://github.com/kubernetes/kops) are used to create and manage AWS environments and Kubernetes clusters.

**Kops** is used to provision and manage Kubernetes clusters (EC2 instances, ELBs, Security Groups, AutoScaling Groups, Route53 DNS entries, etc).

**Terraform** is used to provision non-Kubernetes/off-cluster resources (RDS, S3, EFS, IAM, etc).

Because both Terraform and Kops create AWS resources, and in two different phases, the order of execution during environment creation, and separation of responsibilities between the two is important. The current high-level execution plan is:

1. `terraform apply` for 'global' resources shared across all environments. This currently consists of root DNS records, and S3 buckets for Terraform and Kops state storage. Once these resources have been created in AWS no further interaction is required when adding/editing/deleting environments.
2. `terraform apply` for the specific environment. This creates the VPC, internet gateway, VPC subnets for non-cluster resources (RDS etc.), env-specific DNS records, S3 data buckets for the platform, and EFS file storage.
3. `kops create|update cluster` for the Kubernetes cluster itself. This creates EC2 instances, VPC subnets, AutoScaling groups, Security Groups, ELBs, etc.

To tie Terraform and Kops together as much (and in as sane a way) as possible, a shell script should be present in each environment, as per [env-dev/create_kops_cluster.sh](https://github.com/ministryofjustice/analytics-qnd-ops/blob/master/infra/terraform/env-dev/create_kops_cluster.sh), which takes output values from Terraform and passes them to `kops create cluster` as input arguments.

Once the cluster is created, both terraform resources and kops clusters can be edited and applied in-place without requiring interaction with the other; e.g. `kops edit cluster` can be run and applied without any interaction with Terraform, and `terraform apply` can be run without interacting with Kops.

## Terraform variables

As some variables are essentially constant across all environments, a `global_terraform.tfvars` file is present in the `infra/terraform` directory - this currently contains our AWS region, and S3 bucket and object name for the Terraform state store.

Each environment should also contain a `terraform.tfvars` file for per-env variables.

As we have at least two `.tfvars` files for each environment, every call to `terraform plan|apply|output` etc must reference these files, e.g. `terraform plan -var-file terraform.tfvars -var-file ../global_terraform.tfvars`

## Secrets and git-crypt

Terraform `tfvars.tf` files contain sensitive information, so are encrypted using `git-crypt`. To work with this repository you must ask a repo member or admin to add your GPG key.

## Managing global AWS resources, and preparing Terraform remote state

The global AWS resources (DNS and S3 buckets) will almost certainly already be in place - if not, ask a repo admin. However, you must initialize Terraform's remote state so that per-environment Terraform resources can reference it. To initialize remote state in your working repository:

1. `$ cd infra/terraform/base` - (you must cd to this directory)
2. `$ ./init.sh`

Initialization is only required once per local checkout.



## Step by step - create an environment from existing Terraform resources

This example will create the `dev` environment.

### Prep

1. Ensure your GPG key has been added to `git-crypt` (ask an admin)
2. Check out this repository

### Initialize Terraform remote state

1. `$ cd infra/terraform` - (you must cd to this directory)
2. `$ ./init_env_terraform_state.sh $BUCKET_NAME env-dev eu-west-1` - where $BUCKET_NAME is the existing terraform S3 bucket. The same bucket is used for all environments.

### Create AWS resources

1. `$ cd env-dev`
2. `$ terraform plan -var-file terraform.tfvars -var-file ../global_terraform.tfvars` - pay attention to Terraform's execution plan and ensure it's what you expect
3. `$ terraform apply -var-file terraform.tfvars -var-file ../global_terraform.tfvars`

AWS resources should now be in place

### Create Kubernetes cluster

1. Install [kubectl](https://kubernetes.io/docs/user-guide/prereqs/) if you haven't already
2. Create an SSH key: `$ ssh-keygen -t rsa -b 4096 -C "your@email.com"`
3. Edit cluster parameters in `create_kops_cluster.sh` if necessary (e.g. number of worker nodes, instance size, Kubernetes version etc.)
4. `$ ./create_kops_cluster.sh PATH_TO_SSH_KEY`
5. Get the cluster name from Terraform: `$ CLUSTER_NAME=$(terraform output --module=cluster_dns dns_zone_domain)`
6. Once Kops has generated the cluster configuration: `$ kops update cluster $CLUSTER_NAME --yes`
7. Kops will now create the cluster - currently this will take around 15 minutes. Kops will also add credentials to you `~/.kube/config` file and set this cluster as the current context

### Verify cluster creation
1. `$ kubectl cluster-info`

If kubectl is unable to connect, the cluster is still starting, so wait a minute or two and try again. Once `cluster-info` returns Kubernetes master and KubeDNS your cluster is ready.

### Modifying AWS and cluster post-creation
Once all of the above has been carried out, both Terraform and Kops state buckets will be populated, and your local directory will be configured to push/pull from those buckets, so changes can be made without further configuration.

* To make changes to AWS resources, edit or add Terraform `.tf` files, then:  
  * `$ terraform apply -var-file terraform.tfvars -var-file ../global_terraform.tfvars`
* To make changes to the cluster:  
  * `$ kops edit cluster $CLUSTER_NAME`
  * Make changes to the cluster spec and save
  * Apply changes: `$ kops update cluster $CLUSTER_NAME --yes`