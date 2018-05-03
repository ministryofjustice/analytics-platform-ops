## Create K8s EBS etcd volume snapshots Lambda function
=======================================================

Prerequisites
-------------

You'll need a working [Go](www.golang.org/doc/) environment to build a distribution

For working with the [Go](www.golang.org) runtime in AWS Lambda. See [lambda-go-how-to-create-deployment-package](https://docs.aws.amazon.com/lambda/latest/dg/lambda-go-how-to-create-deployment-package.html)

To Build and Deploy
---------

The Lambda execution environment uses a Linux kernel, so you'll need to build the binary for linux
```
GOOS=linux go build create_etcd_ebs_snapshot.go 

```

Once you have built a distribution with the command above see [Lambda_EBS_Module](../../../modules/lambda_ebs_mgmt/README.md)
for an example on how to deploy

To Test
-------

__Optionally__ set filter tags to filter ec2 instances.  My filter below states that I only want to target 
ec2 instances with a tag that matches __key__ `aws:autoscaling:groupName` with the __value__ `webservers`.

```
export INSTANCE_KEY=aws:autoscaling:groupName
export INSTANCE_VALUE=webservers
```

__Note__: If testing locally, you may need to set the __region__ in your `~/.aws/config` file or by setting 
`AWS_REGION` environment variable.

Test by running
`go run create_etcd_ebs_snapshot.go`
