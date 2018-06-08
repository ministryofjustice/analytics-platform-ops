## Prune EBS Snapshots

Prerequisites
-------------

You'll also need a working [Go](www.golang.org/doc/) environment to build a distribution

For working with the [Go](www.golang.org) runtime in AWS Lambda. See [lambda-go-how-to-create-deployment-package](https://docs.aws.amazon.com/lambda/latest/dg/lambda-go-how-to-create-deployment-package.html)

To Build and Deploy
---------

The Lambda execution environment uses a Linux kernel, so you'll need to build the binary for linux
```
GOOS=linux go build prune_ebs_snapshots.go 

```

Once you have built a distribution with the command above. Deploy the lambda function with the [terraform](https://www.terraform.io/) commands below

__Note__ the commands below assume you are at the __root__ of the repository

```
terraform plan -target=module.kubernetes_prune_ebs_snapshots -var-file=infra/terraform/global/assets/prune_ebs_snapshots/vars_prune_ebs_snapshots.tfvars

terraform apply -target=module.kubernetes_prune_ebs_snapshots -var-file=infra/terraform/global/assets/prune_ebs_snapshots/vars_prune_ebs_snapshots.tfvars
```

To Test
-------

__Optionally__ set environment variables to filter resources.  My filter below states that I only want to target 
ebs snapshots with a tag that matches __key__ `etcd` with the __value__ `1` that are at least a week old.

```
export SNAPSHOT_TAG_KEY=etcd
export SNAPSHOT_TAG_VALUE=1
export DAYS_OLD=7
```

__Note__: If testing locally, you may need to set the __region__ in your `~/.aws/config` file or by setting 
`AWS_REGION` environment variable.

Test by running
`go run prune_ebs_snapshots.go`
