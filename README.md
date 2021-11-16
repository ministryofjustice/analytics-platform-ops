# MOJ Analytics Platform Ops and Infrastructure

[Kubernetes]-based data analysis platform, using [Terraform], [Kops] and [Helm] charts.

Contact alex.craciun@digital.justice.gov.uk if you're in government and interested in talking to us about analytics platforms.

## Directory structure

* `infra`
[Terraform] resources for AWS infrastructure and [Kops] resources for Kubernetes clusters

## Prerequisites
Install:

  * [Terraform]
  * [Kops v1.11+][kops]
  * [git-crypt][gitcrypt]

## Infrastructure Overview

A combination of [Terraform](https://www.terraform.io) and [Kops](https://github.com/kubernetes/kops) are used to create and manage AWS environments and Kubernetes clusters.

**[Terraform]** is used to provision the base AWS environment (VPC, NAT Gateways, subnets etc.) and non-Kubernetes, off-cluster resources such as S3, EFS, IAM policies, Lambda functions, etc).

**[Kops]** is used to provision and manage Kubernetes clusters (EC2 instances, ELBs, Security Groups, AutoScaling Groups, Route53 DNS entries, etc).

**[Helm]** is used to manage installation and updates of all Kubernetes resources, including end-user software.

This project and repository is designed to manage multiple environments (staging, test, production, etc), so contains some global elements that are used by all environments, namely S3 buckets for Terraform and Kops, and a Route53 DNS zone.

Because both Terraform and Kops create AWS resources in two different phases, the order of execution during environment creation, and separation of responsibilities between the two is important. The current high-level execution plan is:

1. `terraform apply` within `infra/terraform/global` for 'global' resources shared across all environments. This currently consists of root DNS records, and S3 buckets for Terraform and Kops state storage. These resources only needed to be created once for all environments.
2. `terraform workspace [new|select] $ENVNAME && terraform apply` within `infra/terraform/platform` for the specific environment. This creates the VPC, subnets, gateways etc. for the Kubernetes cluster, a Route53 hosted zone for the environment, S3 data buckets for the platform, and NFS file storage.
3. `kops create|update cluster` for the Kubernetes cluster itself. This creates EC2 instances, AutoScaling groups, Security Groups, ELBs, etc. within the Terraform-created VPC.

## Secrets and git-crypt

Terraform `terraform.tfvars` files contain sensitive information, so are encrypted using `git-crypt`. To work with this repository you must ask a repo member or admin to add your GPG key. You can follow [these instructions](https://github.com/ministryofjustice/analytics-platform-config/blob/master/README.md#git-crypt), but remember to change the repo name from `analytics-platform-config` to `analytics-platform-ops`.

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

### Compiling Go functions

You need to compile some Go scripts (because AWS Lambda requires binaries). Follow the build instructions found in these READMEs:

* [Create etcd EBS Snapshot README](infra/terraform/global/assets/create_etcd_ebs_snapshot/README.md)
* [Prune EBS Snapshot README](infra/terraform/global/assets/prune_ebs_snapshots/README.md)

If you miss this step, you'll get an error to do with `archive_file.create_etcd_ebs_snapshot`/`archive_file.prune_ebs_snapshots` not finding a file (the compiled one).

### Elastic Search

Setup a deployment of ElasticSearch using the elastic.co SaaS service. (They offer a free 15 day trial account which we can use for tests.)

'Create deployment' with settings:

* Provider: AWS
* Region: EU (Ireland)

On completion, fill in the `es_*` settings in the global `terraform.tfvars` - see below.


### Global terraform.tfvars

You need to set the values in `infra/terraform/global/terraform.tfvars`:

| Variable  | Value |
| ------------- | ------------- |
| `region` | `eu-west-1` |
| `terraform_base_state_file`| "base/terraform.tfstate" |
| `kops_bucket_name` | The name of an S3 bucket to store the kops state |
| `platform_root_domain` | The domain name that the platform will sit under e.g. `mojanalytics.xyz` |
| `es_domain` | In the elastic.co sidebar click "ElasticSearch" and from "API Endpoint" use the domain e.g. `abc123.eu-west-1.aws.found.io` |
| `es_port` | `9243` |
| `es_username` | `elastic` |
| `es_password` | This is displayed once only, at the point of completing the Elastic Search deployment |
| `global_cloudtrail_bucket_name` | Choose an S3 bucket name for cloudtrail |
| `uploads_bucket_name` | Choose an S3 bucket name for uploads |
| `s3_logs_bucket_name` | Choose an S3 bucket name for S3 logs |
| `helm_repo_s3_bucket_name` | Name of S3 bucket containing the helm charts repository |

The checked-in `terraform.tfvars` is for MoJ, so if your platform is for another purpose either edit it in a fork of this repo, or create a separate .tfvars file with all the variable values you wish to override and specify it on the following (global) `terraform plan` and `terraform apply` steps with a parameter like: `-var-file="godobject.tfvars"`.

### Domain name

The platform runs on lots of subdomains stemming off a domain name or subdomain.

It's easiest if you use a domain name that has been purchased using the same AWS account as the platform runs in, but other configurations are possible. See: https://github.com/kubernetes/kops/blob/master/docs/aws.md#configure-dns

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

# Configure (in .terraform) the remote state and download the required modules
terraform init -backend-config "bucket=$TERRAFORM_STATE_BUCKET_NAME"
# Note: if you configure the wrong backend, you'll need to delete your `.terraform` before running this again.

# You can check the configured platform backend:
grep \"key\" -C 1 .terraform/terraform.tfstate

# HACK: You need to do this 'terraform apply' before the main 'terraform plan' or you get this error:
# `module.ses_domain.aws_route53_record.domain_amazonses_dkim_verification_record: aws_route53_record.domain_amazonses_dkim_verification_record: value of 'count' cannot be computed`
terraform apply -target aws_ses_domain_dkim.domain_verification

# check the Terraform plans to create global infra (e.g. the Kops S3 bucket and a root DNS zone in Route53)
terraform plan

# NB You can usually ignore these actions, which fire every time due to `triggers {force_rebuild = "${timestamp()}"`:
#    <= module.aws_account_logging.data.archive_file.cloudtrail_zip
#    <= module.aws_account_logging.data.archive_file.s3logs_zip
#    ~ module.aws_account_logging.aws_lambda_function.cloudtrail_to_elasticsearch
#    ~ module.aws_account_logging.aws_lambda_function.s3_logs_to_elasticsearch
#    ~ module.aws_account_logging.aws_lambda_function.vpcflowlogs_to_elasticsearch
#    -/+ module.aws_account_logging.null_resource.cloudtrail_install_deps (new resource required)
#    -/+ module.aws_account_logging.null_resource.s3logs_install_deps (new resource required)
#    -/+ module.aws_account_logging.null_resource.vpcflowlogs_install_deps (new resource required)
#    <= module.log_pruning.data.archive_file.prune_logs_zip
#    ~ module.log_pruning.aws_lambda_function.prune_logs
#    -/+ module.log_pruning.null_resource.prune_logs_deps (new resource required)
# and you can usually ignore these because of whitespace issues:
#    ~ module.hmpps_nomis_upload_user.aws_iam_policy.system_user_s3_writeonly
#    ~ module.hmpps_oasys_upload_user.aws_iam_policy.system_user_s3_writeonly

# create resources
terraform apply
```


## Environment setup

### Defining new environment

Give the environment a name - e.g. `dev`. This will be known as $ENVNAME in these instructions.

#### SoftNAS NFS server setup

User network home directories are provided by SoftNAS from AWS Marketplace. There are a few different versions e.g.:

* [SoftNAS from AWS Marketplace](https://aws.amazon.com/marketplace/pp/B01BJC4JI6?qid=1495795249740&sr=0-3&ref_=srh_res_product_title) is "For Lower Compute Requirements".
* [SoftNAS Cloud Developer Edition 4.0.x](https://aws.amazon.com/marketplace/pp/B06Y5W7TKY?qid=1533814033150&sr=0-4&ref_=srh_res_product_title) is limited to 250GB but the software is **free** - you just pay $0.085/hr for c5.large EC2 machine.

There are about 20 SoftNAS options on AWS Marketplace, with varying cost models etc, so it's worth evaluating which ones suit your purpose.

Once selected, on the SoftNAS product web page you need to:

1. Click "Continue to Subscribe"
2. Click "Accept terms"
3. Wait 30 seconds before the flash message appears "Thank you for subscribing to this product!"
4. Click "Continue to Configuration" (which has also appeared)
5. Configure:

   * Region: choose the same as chosen for the rest of your platform (e.g. EU Ireland)

   Now record the AMI id (e.g. `ami-22cecec8`) - you'll use this in your .tfvars file in a moment.

6. Click "Continue to Launch"

   * EC2 Instance Type - select a suitable one, considering cost. Record the instance type (e.g. `m5.large`) - you'll use this in your .tfvars file in a moment.

You can now quit the launch process because terraform will do the launch. The important thing is that you've agreed to the licence and recorded the settings for your .tfvars file, needed in a moment.

#### Auth0

1. Create a new tenant:

    1. Log-in to Auth0
    2. Click on your user
    3. In the drop-down menu click "Create tenant"
         * Tenant domain: include the environment name, if not the platform

    NB It's recommended for admins to use Multifactor Authentication (MFA) when accessing the Auth web console, which requires a ["Developer Pro" plan](https://auth0.com/pricing). Currently this costs from $14/month, which works with up to 100 External users (i.e. people using the platform).

2. Create an application:

    1. In the side-bar click "Applications"
    2. Click "Create Application"
         * Name: AWS
         * Application Type: Regular Web Applications
    3. Click "Save"
    4. Click "Settings"
         * Allowed Callback URLs: `https://signin.aws.amazon.com/saml, https://aws.services.$ENVNAME.$domain/callback` (replace the $variables)
         * Allowed Web Origins: `https://aws.services.$ENVNAME.$domain` (replace the $variables)
    5. Click "Save changes"

    Record the Domain and Client ID values - you'll use them in your .tfvars file in a moment.

3. Download SAML2 metadata:

    1. In the side-bar click "Applications"
    2. Click "AWS" (created in previous step)
    3. Click the tab "Addons"
    4. Click "SAML2 Web App"
    5. Click "Save"
    6. Click tab "Usage"
    7. Under "Identity Provider Metadata" (NOT "Certificate"!) click "download"
    8. Refer to `platform-base` Terraform instructions below for information on configuring Terraform to use SAML signon

##### Connections & Applications

In Auth0 you need to create some Connections and Applications.

##### Connections

###### GitHub
 1. Click GitHub to set it up
 2. Follow: [Connect your app to GitHub](https://auth0.com/docs/connections/social/github)
    Make sure you create the connection in your organization, not your own account (e.g. https://github.com/organizations/moj-analytical-services/settings/applications). Complete the Client ID and Client Secret on GitHub.
 3. Check these boxes:
    * Email address
    * read:user
    * read:org
 4. Click "Save"
 5. Click "Applications" tab and switch on all applications that need login, including: auth0-authz, AWS, RStudio, Grafana, Control Panel, kubectl-oidc, Jupyter Lab, Concourse, Airflow, auth0-logs-to-logstash.
 6. Click "Save" and "X" to close the dialog.
####### Google
1. Set the apps that Google can be used sign in to:
     1. Still in "Connections" | "Social", click "Google" then "Applications"
     2. Ensure only these are switched on: Default App, auth0-authz, API Client, auth0-github-deploy, API Explorer Client, API Explorer Application, auth0-logs-to-logstash, Airflow.

###### NOMIS & Other `oauth2` Connections
To create additional connections like `nomis` there is a script that you can run, follow it's
own [README](./scripts/auth0connections/README.md) for instructions on how to set it up.

Once it is set up run:

```bash
./scripts/auth0connections/auth0connections.py -f PATH/to/config/repo/chart-env-config/ENV/auth0connections.yaml create
```

or the equivalent docker command if you're running it in docker.

###### Applications

###### kubectl-oidc application

1. Login to https://manage.auth0.com/ and select the tenant for your environment
2. In the side-bar click "Applications"
3. Click "Create Application"
      * Name: kubectl-oidc
      * Application Type: Regular Web Applications
4. Click "Save"
5. Click "Settings" tab
      * Allowed Callback URLs: `http://localhost:3000/callback, https://cpanel-master.services.$ENVNAME.$domain/callback`
      (replace the $variables)
      * Allowed Web Origins: `http://localhost:3000, https://cpanel-master.services.$ENVNAME.$domain` (replace the $variables)
      * Allowed Logout URLs: `http://localhost:3000, https://cpanel-master.services.$ENVNAME.$domain` (replace the $variables)
      * JWT Expiration (seconds): `36000` (10 hours)
6. Click "Save changes"
7. Click "Connections" tab
8. Switch OFF "Database" and "Google"
9. In the side-bar click "Connections" then "Social"
10. Click GitHub
     1. Click "Applications" tab and switch on `kubectl-oidc` application
     1. Click "Save" and "X" to close the dialog.

The Client ID and Client Secret values will be used in various helm chart configurations.

#### Terraform

**You must have valid AWS credentials in [`~/.aws/credentials`](http://docs.aws.amazon.com/amazonswf/latest/awsrbflowguide/set-up-creds.html)**

Terraform resources are split into two resource sets / state objects:

1. `platform-base` - essential requirements for kops/kubernetes
2. `platform` - everything else

This split allows kops to provision a Kubernetes cluster after `platform-base` and before `platform` resources are created, so that `platform` resources can reference AWS resources created by kops and Kubernetes, such as node IAM roles.

##### `platform-base` Terraform

Each environment is a Terraform 'workspace'.

To create a new environment in Terraform:
```
# Enter platform-base Terraform resources directory
cd infra/terraform/platform-base

# Set this env var to the same value as before, giving the location of the platform's global terraform state
export TERRAFORM_STATE_BUCKET_NAME=global-terraform-state.example.com

# Configure (in .terraform) the remote state and download the required modules
terraform init -backend-config "bucket=$TERRAFORM_STATE_BUCKET_NAME"
# Note: if you configure the wrong backend, you'll need to delete your `.terraform` before running this again.

# Store the name of the environment in the environment e.g.
export ENVNAME=mytestenv

# List current workspaces
terraform workspace list

# Create the new workspace
terraform workspace new $ENVNAME

# Create vars file with config values for this environment - refer to existing .tfvars files for reference (or create one using the variable names listed in platform/variables.tf)
cp vars/alpha.tfvars vars/$ENVNAME.tfvars
vim vars/$ENVNAME.tfvars
```

| Variable  | Value |
| ------------- | ------------- |
| `region`  | AWS region. This must be a region that supports all AWS services created in `infra/terraform/modules`, e.g. `eu-west-1`  |
| `terraform_bucket_name`  | S3 bucket name for Terraform state (=$TERRAFORM_STATE_BUCKET_NAME) |
| `vpc_cidr`  | IP range for cluster, e.g. `192.168.0.0/16`  |
| `availability_zones`  | AWS availability zones, e.g. `["eu-west-1a", "eu-west-1b", "eu-west-1c"]`. At present three AZs must be used  |
| `oidc_provider_url` | In Auth0 look in the Application called 'AWS' for its domain and manually make it into a URL e.g. `https://dev-analytics-moj.eu.auth0.com/` |
| `oidc_client_id` | In Auth0 look in the Application called 'AWS' for its Client ID. e.g. `0H27Ouhl...` |
| `oidc_provider_thumbprints` | Use Auth0's thumbprints, which are: `["6ef423e5272b2347200970d1cd9d1a72beabc592", "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",]` |
| `idp_saml_domain` | Auth0 tenant domain, minus `http://`, e.g. `dev-analytics-moj.eu.auth0.com` |
| `idp_saml_signon_url` | value of `<SingleSignOnService>` in SAML metadata XML, e.g. `https://dev-analytics-moj.eu.auth0.com/samlp/c6q0KcsL4Kj70T97whsrSarwuYP65353` |
| `idp_saml_logout_url` | value of `<SingleLogoutService>` in SAML metadata XML, e.g. `https://dev-analytics-moj.eu.auth0.com/samlp/c6q0KcsL4Kj70T97whsrSarwuYP65353` |
| `idp_saml_x509_cert` | value of `<X509Certificate>` in SAML metadata XML, e.g. `MIIDEzCCAfugA...` |
| `k8s_version` | kops-supported Kubernetes version |
| `k8s_instancegroup_image` | kops machine image to match `k8s_version` - refer to [kops channel info](https://github.com/kubernetes/kops/blob/master/channels/stable) |


```
# Create Terraform resources
terraform apply -var-file=vars/$ENVNAME.tfvars
```

##### Create Kubernetes cluster

1. Install tools (if you've not already):

* [kubectl](https://kubernetes.io/docs/user-guide/prereqs/)
* [Kops](https://github.com/kubernetes/kops)

2. Set the Kops state store S3 bucket environment variable (see previous step):
  ```
  $ export KOPS_STATE_STORE=s3://$(terraform output kops_bucket_name)
  ```

3. Pass cluster specification from Terraform to Kops and plan cluster resource creation:

  ```
  terraform output kops_spec | kops create -f -
  ```

4. Create SSH keys: `$ ssh-keygen -t rsa -b 4096`

5. Add the .pub key to Kops cluster:
  ```
  kops create secret --name $ENV_DOMAIN sshpublickey admin -i PATH_TO_PUBLIC_KEY
  ```
  Where `$ENV_DOMAIN` is the full DNS name of the cluster, including the base domain, e.g. `dev.mojanalytics.xyz`.

6. Add the DockerHub creds to Kops cluster:

  ```
  kops create secret --name $ENV_DOMAIN create secret dockerconfig -f PATH_TO_CONFIG.JSON
  ```
  Where `$ENV_DOMAIN` is the full DNS name of the cluster, including the base domain, e.g. `dev.mojanalytics.xyz` and
  `PATH_TO_CONFIG.JSON` is the path to the config.json file containing the DockerHub creds.


7. Plan and create cluster:

  ```
  kops update cluster $ENV_DOMAIN
  kops update cluster $ENV_DOMAIN --yes
  ```


### Verify cluster creation
`$ kubectl cluster-info`

If kubectl is unable to connect, the cluster is still starting, so wait a few minutes and try again; Terraform also creates new DNS entries, so you may need to flush your DNS cache. Once `cluster-info` returns Kubernetes master and KubeDNS your cluster is ready and you can proceed to create remaining Terraform `platform` resources.

### kube config

The admin credentials for this cluster needs copying from S3 bucket $KOPS_STATE_STORE to your local disk (`~/.kube/config` by default). This allows you to run kubectl and helm:
```
$ kops export kubecfg $ENV_DOMAIN
```
Other developers can also get those admin credentials for kubectl, with these handy instructions:
```
# You need an AWS user account with access to the S3 bucket named in the KOPS_STATE_STORE environment variable below.
# Configure the aws cli:
aws configure
# Now you can install the cluster's kube config:
export KOPS_STATE_STORE=s3://kops.accelerator.data-science.org
kops export kubecfg accelerator.data-science.org.uk
```

These admin kubectl creds should only be used to do the initial set-up of the cluster. After that, you should use your personal OIDC creds, obtained using a service such as: https://kuberos.services.alpha.mojanalytics.xyz/


##### `platform` Terraform

`platform` Terraform resources must be created *after* kops has successfully deployed a Kubernetes cluster.

Each environment is a Terraform 'workspace'. The workspace name for `platform-base` and `platform` resources **MUST** match.

To complete new environment setup in Terraform:
```
# Enter platform Terraform resources directory
cd infra/terraform/platform

# Store the name of the environment in the environment e.g.
export ENVNAME=mytestenv

# Create the new workspace
terraform workspace new $ENVNAME

# Create vars file with config values for this environment - refer to existing .tfvars files for reference (or create one using the variable names listed in platform/variables.tf)
cp vars/alpha.tfvars vars/$ENVNAME.tfvars
vim vars/$ENVNAME.tfvars
```

| Variable  | Value |
| ------------- | ------------- |
| `region`  | AWS region. This must be a region that supports all AWS services created in `infra/terraform/modules`, e.g. `eu-west-1`  |
| `terraform_bucket_name`  | S3 bucket name for Terraform state (=$TERRAFORM_STATE_BUCKET_NAME) |
| `control_panel_api_db_username` | |
| `control_panel_api_db_password` | |
| `airflow_db_username` | |
| `airflow_db_password` | |
| `ses_ap_email_identity_arn` | Create an SES email address that AP can use to send emails (SES provides the SMTP) and provide the ARN e.g. "arn:aws:ses:eu-west-1:1234567890:identity/user@example.com"
| `softnas_ssh_public_key` | |
| `softnas_ami_id` | e.g. `ami-22cecec8` |
| `softnas_instance_type` | e.g. `m4.large` |
| `softnas_num_instances` | valid values are `1` for a non-HA deployment or `2` for HA |

```
# Create Terraform resources
terraform apply -var-file=vars/$ENVNAME.tfvars
```

### Working with an existing environment

```
# Ensure you're in the platform resources directory
cd infra/terraform/platform
```
If this repo is freshly checked-out you'll need to configure it:
```
# Set this env var to the same value as before, giving the location of the platform's global terraform state
export TERRAFORM_STATE_BUCKET_NAME=global-terraform-state.example.com

# Configure (in .terraform) the remote state and download the required modules
terraform init -backend-config "bucket=$TERRAFORM_STATE_BUCKET_NAME"
# Note: if you configure the wrong backend, you'll need to delete your `.terraform` before running this again.

# You can check the configured platform backend:
grep \"key\" -C 1 .terraform/terraform.tfstate
```
Select the workspace/environment:
```
terraform workspace select $ENVNAME
```
Now you can use commands like `terraform plan` and `terraform apply`.

Note about different backends: if you want to run terraform for another platform, and therefore use a different remote state backend, you should do this in another check-out of this repository.


### Creating AWS resources, or applying changes to existing environment

Once remote Terraform state has been configured you can now apply changes to existing environments, or create a new environment:

```
# Enter platform resources directory
cd infra/terraform/platform

# Select environment
terraform workspace select $ENVNAME

# Plan and preview changes - you must use the correct .tfvars file for this environment
terraform plan -var-file=vars/$ENVNAME.tfvars

# NB You can usually ignore this action, which fires every time due whitespace issues:
#    ~ module.data_buckets.aws_s3_bucket_policy.source

# Apply the above changes
terraform apply -var-file=vars/$ENVNAME.tfvars
```

Note:

Once complete your base AWS resources should be in place

### Helm setup

Because the k8s cluster is configured to use RBAC, Helm's Tiller should use its own service account.
```
# Create Tiller's service account
kubectl create -f config/helm/tiller.yml

# Install Tiller, configured to use the new service account
helm init --service-account tiller

# Check it deployed the Tiller image ok
kubectl describe deployment tiller-deploy -n kube-system
```

### kube2iam setup

An annotation needs adding to allow roles to be assumed:

```
kubectl edit namespace default
```
and under metadata add 'annotations', ensuring you substitute your environment name for `(dev|alpha)`:
```
metadata:
  annotations:
    iam.amazonaws.com/allowed-roles: '["(dev|alpha)_.*"]'
```

### Install basic charts

For any AP you need to install a couple of basic charts now:

* init-platform
* nginx-ingress

For the instructions, see: https://github.com/ministryofjustice/analytics-platform-helm-charts/blob/master/charts/README.md

### Ingress DNS setup

Some extra DNS entries need creating for ingress:
```
./ingress_load_balancer_create_dns.sh $ENV_DOMAIN
```

### Modifying AWS and cluster post-creation
Once all of the above has been carried out, both Terraform and Kops state buckets will be populated, and your local directory will be configured to push/pull from those buckets, so changes can be made without further configuration.

* To make changes to AWS resources, edit or add Terraform `.tf` files, then:
  * `$ terraform plan`
  * `$ terraform apply`
* To make changes to the cluster, edit Kops cluster specs in place, as unfortunately YAML files can not be passed to the `edit` command. You should however strive to keep your local YAML files in sync with Kops remote files, so that environments can be easily recreated in the future:
  * `$ kops edit cluster $ENV_DOMAIN`
  * Make changes to the cluster spec and save
  * Apply changes: `$ kops update cluster $ENV_DOMAIN --yes`

[terraform]: https://www.terraform.io
[kops]: https://github.com/kubernetes/kops
[helm]: https://github.com/kubernetes/helm/
[kubernetes]: https://kubernetes.io
[gitcrypt]: https://www.agwa.name/projects/git-crypt/

### Auth0 Rules & Hosted Pages

Auth0 needs 'rules' installed, to ensure only certain people can log-in, for example. We also use the 'Hosted pages' feature to customize the login page. Both are continuously deployed with the same setup, as follows.

Find the rules in this repo: https://github.com/ministryofjustice/analytics-platform-auth0
in the dev or alpha branches. Create a new branch (or fork it if another organization) and adapt the following settings in them:

| Setting | Description |
| ------- | ----------- |
| `targeted_clients` | The 'Client ID' of the Auth0 application "kubectl-oidc" |
| `namespace` | Set to: `https://api.$ENVNAME.$DOMAIN/claims/` but replace the variables |
| `AUTHENTICATOR_LABEL` | The name of the platform, as shown when doing Auth0 MFA |
| `whitelist` | The GitHub organizations whose members are authorized to access the platform |

You can use the Auth0 web ui to add the rules, or set-up auto deployment like this:
1. In Auth0 click "Extensions" in the side menu.
2. Search for and click "GitHub Deployments"
3. Fill in options, e.g.:
   * GITHUB_REPOSITORY: ministryofjustice/analytics-platform-auth0
   * GITHUB_BRANCH: alpha
   * GITHUB_TOKEN: (create one this from: https://github.com/settings/tokens and select the "repo" scope)
4. Click "Save"
5. Click "Installed Extensions" tab, then click "GitHub Integration" and agree to access.
6. Find the text "A webhook has to be created <$repo>" and open the link a new tab. Note: actually you need to create the webhook yourself!
7. Click "Add webhook" and copy the three option values from the previous browser tab. Then click "Add webhook".
8. Click "Deployments" tab and click "Deploy" which should show add a line with Status of "Success".
9. https://manage.auth0.com/#/rules should now be populated


### NFS server administration


NFS server storage volumes are provided by EBS volumes defined in `infra/terraform/modules/user_nfs_softnas/ebs.tf`, and additional volumes can be defined there as necessary. By default two EBS volumes are created for each Terraform resource defined, to mirror storage between both SoftNAS instances.

SoftNAS does not support any form of configuration management, so NFS server setup must be performed manually via the SoftNAS web interface. As SoftNAS is deployed into private subnets, you must use an SSH tunnel to access the admin interface:

Alpha

`$ ssh -AL 8443:softnas-1.alpha.mojanalytics.xyz:443 ubuntu@bastion.alpha.mojanalytics.xyz -N`

Dev

`$ ssh -AL 8443:softnas-0.dev.mojanalytics.xyz:443 ubuntu@bastion.dev.mojanalytics.xyz -N`


The instance can then be accessed on `https://localhost:8443/`.

#### NFS share setup

1. Login to the admin UI of the `softnas-0` instance. Default username is `softnas` and the default password is the AWS instance ID.
2. Registration - you can skip.
3. Agreement - agree to.
4. Go to `Storage > Disk Devices` and create partitions on attached disks by clicking `Partition All`
5. Go to `Storage > Storage Pools` and create a pool called `users` and attach disks. Choose `JBOD` pool type - RAID arrays are redundant given that we are using RAID-backed EBS volumes.
6. Go to `Storage > Volumes` and create a volume called `homes` using the `users` pool with an NFS export, which should be selected by default.

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

## What's next

Now you have the infrastructure set-up, next install other charts: https://github.com/ministryofjustice/analytics-platform-helm-charts/blob/master/README.md


Ensure you refer to the READMEs for each chart, for additional setup e.g. [Auth0 setup for cpanel](https://github.com/ministryofjustice/analytics-platform-helm-charts/blob/master/charts/cpanel/README.md)
