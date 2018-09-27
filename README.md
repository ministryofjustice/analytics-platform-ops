# MOJ Analytics Platform Ops and Infrastructure

[Kubernetes][kubernetes]-based data analysis platform, using [Terraform][terraform], [Kops][kops] and [Helm][helm] charts.

Contact robin.linacre@digital.justice.gov.uk if you're in government and interested in talking to us about analytics platforms.

## Directory structure

* `infra`
[Terraform][terraform] resources for AWS infrastructure and [Kops][kops] resources for Kubernetes clusters

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

1. `terraform apply` within `infra/terraform/global` for 'global' resources shared across all environments. This currently consists of root DNS records, and S3 buckets for Terraform and Kops state storage. These resources only needed to be created once for all environments.
2. `terraform workspace [new|select] $envname && terraform apply` within `infra/terraform/platform` for the specific environment. This creates the VPC, subnets, gateways etc. for the Kubernetes cluster, a Route53 hosted zone for the environment, S3 data buckets for the platform, and NFS file storage.
3. `kops create|update cluster` for the Kubernetes cluster itself. This creates EC2 instances, AutoScaling groups, Security Groups, ELBs, etc. within the Terraform-created VPC.

## Secrets and git-crypt

Terraform `terraform.tfvars` files contain sensitive information, so are encrypted using `git-crypt`. To work with this repository you must ask a repo member or admin to add your GPG key.

If you get merge conflicts on gitcrypted files then by default it will not put the <<< ---- >>> sections to show you the different versions. You can fix this behaviour by specifying this custom merge driver in your .git/config:
```
[merge "git-crypt"]
       name = A custom merge driver used to merge git-crypted files.
       driver = ./gitcrypt-merge-tool.sh %O %A %B
       recursive = binary
```
See: https://github.com/AGWA/git-crypt/issues/140#issuecomment-361031719

## Kubernetes resource management

All [Kubernetes][kubernetes] resources are managed as [Helm][helm] charts, the Kubernetes package manager. Analytics-specific charts are served via our [Helm repository](http://moj-analytics-helm-repo.s3-website-eu-west-1.amazonaws.com) - source code is in the [ministryofjustice/analytics-platform-helm-charts](https://github.com/ministryofjustice/analytics-platform-helm-charts) repository, and chart values for each environment are stored in the [ministryofjustice/analytics-platform-config](https://github.com/ministryofjustice/analytics-platform-config) repository.

## Global setup

Global AWS resources (DNS and S3 buckets) are resources which are shared or referred to by all instances of the platform, and only need to be created once. These resources have likely already been created, in which case you can skip ahead to remote state setup, but if you are starting from a clean slate:

### Creating global AWS resources, and preparing Terraform remote state

**You must have valid AWS credentials in [`~/.aws/credentials`](http://docs.aws.amazon.com/amazonswf/latest/awsrbflowguide/set-up-creds.html)**

```
# Create an S3 bucket for the platform's terraform state
# Choose a unique name for this platform and save it in an env var:
export TERRAFORM_STATE_BUCKET_NAME=global-terraform-state.example.com
# Now create the bucket and set options:
aws s3api create-bucket --bucket $TERRAFORM_STATE_BUCKET_NAME --region=eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1
aws s3api put-bucket-versioning --bucket $TERRAFORM_STATE_BUCKET_NAME --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket $TERRAFORM_STATE_BUCKET_NAME --server-side-encryption-configuration 'rule {
      apply_server_side_encryption_by_default {
        sse_algorithm: "AES256"
      }
    }'

# Enter global Terraform resources directory
cd infra/terraform/global

# set up remote state backend and pull modules
terraform init -backend-config "bucket=$TERRAFORM_STATE_BUCKET_NAME"

# check that Terraform plans to create two S3 buckets (Terraform and Kops state) and a root DNS zone in Route53
terraform plan

# create resources
terraform apply
```

### NFS server licensing

User network home directories are provided by [SoftNAS from AWS Marketplace](https://aws.amazon.com/marketplace/pp/B01BJC4JI6?qid=1495795249740&sr=0-3&ref_=srh_res_product_title). The default image defined in Terraform uses a per-terabyte consumption billing model; if required storage exceeds 1TB the [per server version](https://aws.amazon.com/marketplace/pp/B00PJ9FGVU?qid=1495795249740&sr=0-2&ref_=srh_res_product_title) will be more cost effective.

**Before proceeding with setup of a new environment the SoftNAS subscription must be accepted manually at the URL(s) above.**

### Defining new environment


#### Terraform

**You must have valid AWS credentials in [`~/.aws/credentials`](http://docs.aws.amazon.com/amazonswf/latest/awsrbflowguide/set-up-creds.html)**

```
# Enter platform Terraform resources directory
cd infra/terraform/platform

# Initialize remote state and pull required modules (check the env variable is still set from earlier on)
terraform init -backend-config "bucket=$TERRAFORM_STATE_BUCKET_NAME"

# Create a new workspace - 'workspace' and 'environment' are interchangeable concepts here
terraform workspace new $envname

# Create vars file with config values for this environment - refer to existing .tfvars files for reference
vim infra/terraform/platform/vars/$envname.tfvars 
```

| Variable  | Value |
| ------------- | ------------- |
| `domain`  | Base domain name for platform, e.g. `dev.example.com`. This must be a subdomain of a domain already present in Route53 (e.g. `example.com`), and all services will be created under this subdomain (e.g. `grafana.dev.example.com`)  |
| `region`  | AWS region. This must be a region that supports all AWS services created in `infra/terraform/modules`, e.g. `eu-west-1`  |
| `terraform_bucket_name`  | S3 bucket name for Terraform state (=$TERRAFORM_STATE_BUCKET_NAME) |
| `terraform_base_state_file`  | Path for global Terraform state (as specified in global/main.tf `backend.s3.key`, e.g. `base/terraform.tfstate`) |
| `vpc_cidr`  | IP range for cluster, e.g. `192.168.0.0/16`  |
| `availability_zones`  | AWS availability zones, e.g. `eu-west-1a, eu-west-1b, eu-west-1c`  |


### Working with an existing environment
You must initialize your local Terraform environment to work with remote state stored in the S3 bucket created above before continuing.

```
# Enter platform resources directory
cd infra/terraform/platform

# Select environment
terraform workspace select $envname

# Initialize remote state and pull required modules
terraform init
```

### Creating AWS resources, or applying changes to existing environment

Once remote Terraform state has been configured you can now apply changes to existing environments, or create a new environment:

```
# Enter platform resources directory
cd infra/terraform/platform

# Select environment
terraform workspace select $envname

# Plan and preview changes - you must use the correct .tfvars file for this environment
terraform plan -var-file=vars/$envname.tfvars

# Apply the above changes
terraform apply -var-file=vars/$envname.tfvars
```

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
[gitcrypt]: https://www.agwa.name/projects/git-crypt/

### NFS server administration

By default two SoftNAS instances are deployed, to provide data replication and high-availability. This can be changed to a single-server deployment by changing the `user_nfs_softnas.num_instances` Terraform variable to `1`.

NFS server storage volumes are provided by EBS volumes defined in `infra/terraform/modules/user_nfs_softnas/ebs.tf`, and additional volumes can be defined there as necessary. By default two EBS volumes are created for each Terraform resource defined, to mirror storage between both SoftNAS instances.

SoftNAS does not support any form of configuration management, so NFS server setup must be performed manually via the SoftNAS web interface. As SoftNAS is deployed into private subnets, you must use an SSH tunnel to access the admin interface:

`$ ssh -L 8443:softnas-0.dev.mojanalytics.xyz:443 -L 8444:softnas-1.dev.mojanalytics.xyz:443 admin@bastion.dev.mojanalytics.xyz -N`

The two instances can then be accessed on `https://localhost:8443/` and `https://localhost:8444/`.

#### NFS share setup

1. Login to the admin UI of the `softnas-0` instance. Default username is `softnas` and the default password is the AWS instance ID.
2. Go to `Storage > Disk Devices` and create partitions on attached disks.
3. Go to `Storage > Storage Pools` and create a pool called `users` and attach disks. Choose `JBOD` pool type - RAID arrays are redundant given that we are using RAID-backed EBS volumes.
4. Go to `Storage > Volumes` and create a volume called `homes` using the `users` pool with an NFS export, which should be selected by default.

#### NFS replication and high availability setup

##### Replication
1. Login to the admin UI of the `softnas-0` instance. Default username is `softnas` and the default password is the AWS instance ID.
2. Go to `SnapReplicate` settings
3. Click `Add replication`
4. Follow the setup wizard, providing the private IP and SoftNAS login details for the `softnas-1` instance when prompted
5. Login to the admin UI of `softnas-1` and check the `SnapReplicate` section to confirm that replication setup was successful

##### High Availability
1. Login to the admin UI of the `softnas-0` instance. Default username is `softnas` and the default password is the AWS instance ID.
2. Go to `SnapReplicate` settings
3. Click `Add SnapHA`
4. Enter a contact email address for monitoring alerts
5. Click `Add SnapHA` again
6. Follow the setup wizard. The "VirtualIP" the wizard requests is defined in Terraform as `172.16.0.1`. If the wizard complains about invalid AWS credentials, try again - the wizard seems somewhat glitchy at this point
7. Login to the admin UI of `softnas-1` and check the `SnapReplicate` section to confirm that HA setup was successful

The SoftNAS secondary will monitor availability of the primary, and take over primary status if it cannot ping the current primary. Takeover is performed by updating the AWS routing tables to point the VirtualIP address to the current secondary. Refer to the [SoftNAS HA admin guide](https://www.softnas.com/docs/softnas/v3/snapha-html/ha_operations.html) for more info on how to manage replacement of failed instances, and other HA operations.
