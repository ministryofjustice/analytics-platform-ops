## Create K8s EBS etcd volume snapshots Lambda function
=======================================================

Prerequisites
-------------

You'll need a working [Go](www.golang.org/doc/) environment to build a distribution

For working with the [Go](www.golang.org) runtime in AWS Lambda. See [lambda-go-how-to-create-deployment-package](https://docs.aws.amazon.com/lambda/latest/dg/lambda-go-how-to-create-deployment-package.html)

To Build
--------

The Lambda execution environment uses a Linux kernel, so you'll need to build the binary for linux

A good way to do this if you don't have Go installed is to use Docker:
```
cd infra/terraform/global/assets/create_etcd_ebs_snapshot/
docker run -it -v "$(pwd)":/src golang:alpine sh
```
This will start a Docker container with Go installed and launch a shell. From
there you need to install git and the aws client library:
```
cd /src
apk add git
go get github.com/aws/aws-sdk-go
```
Then you can compile the binary using the following command:
```
GOOS=linux go build -o create_etcd_ebs_snapshot main.go
```

To Deploy
---------

Once you have built a binary/distribution with the command above, deploy the lambda function with the [terraform](https://www.terraform.io/) commands below

__Note__ the commands below assume you are at the __root__ of the repository

```
terraform plan -target=module.kubernetes_create_etcd_ebs_snapshots -var-file=infra/terraform/global/assets/create_etcd_ebs_snapshots/vars_create_etcd_ebs_snapshots.tfvars

terraform apply -target=module.kubernetes_create_etcd_ebs_snapshots -var-file=infra/terraform/global/assets/create_etcd_ebs_snapshots/vars_create_etcd_ebs_snapshots.tfvars
```

To Test
-------

__Optionally__ set filter tags to filter ec2 instances.  My filter below states that I only want to target 
ec2 instances with a tag that matches __key__ `aws:autoscaling:groupName` with the __value__ `webservers`.

__Optionally__ set a tag on the resulting snapshot. Here I am setting a tag `db_vol:true` on the snapshot.


```
export INSTANCE_TAG_KEY=aws:autoscaling:groupName
export INSTANCE_TAG_VALUE=webservers
export TAG_KEY=db_vol
export TAG_VALUE=true
```

__Note__: If testing locally, you may need to set the __region__ in your `~/.aws/config` file or by setting 
`AWS_REGION` environment variable.

Test by running
`go run main.go`
