## Lambda Ebs Management 
====================

Used to schedule ebs tasks 

Module Input Variables
----------------------

- `lambda_function_name` - Name for Lambda function
- `lambda_runtime` - A [valid](http://docs.aws.amazon.com/cli/latest/reference/lambda/create-function.html#options) Lambda runtime environment. Defaults to `go1.x`
- `zipfile` - Path to zip archive containing Lambda function
- `handler` - The entrypoint into your Lambda function, in the form of `filename.function_name`. For `Golang` this must match `lambda_function_name`
- `schedule_expression` - A [valid rate or cron expression](http://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html)
- `source_code_hash` - The base64 encoded sha256 hash of the archive file - see TF [archive file provider](https://www.terraform.io/docs/providers/archive/d/archive_file.html)
- `timeout` - (optional) The amount of time your Lambda Function has to run in seconds. Defaults to 3. See [Limits](https://docs.aws.amazon.com/lambda/latest/dg/limits.html)
- `enabled` - (optional) Boolean expression. If false, the lambda function and the cloudwatch schedule are not set. Defaults to `true`.
- `instance_tag_key` - (optional) The key of the tag to filter instances on
- `instance_tag_value` - (optional) The value of the tag to filter instances
- `lambda_policy` - The IAM policy document.  Usually JSON 

Usage 
-----

```
data "template_file" "lambda_create_snapshot_policy" {
  template = "${file("assets/create_etcd_ebs_snapshot/lambda_create_snapshot_policy.json")}"
}

data "archive_file" "kubernetes_etcd_ebs_snapshot_code" {
  source_file = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot"
  output_path = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot.zip"
  type        = "zip"
}

module "kubernetes_etcd_ebs_snapshot" {
  source               = "../modules/lambda_ebs_mgmt"
  lambda_function_name = "create_etcd_ebs_snapshot"
  zipfile              = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot.zip"
  handler              = "create_etcd_ebs_snapshot"
  source_code_hash     = "${data.archive_file.kubernetes_etcd_ebs_snapshot_code.output_base64sha256}"
  instance_tag_key     = "k8s.io/role/master"
  instance_tag_value   = "1"
  lamda_policy         = "${data.template_file.lambda_create_snapshot_policy.rendered}"
}
```

```
terraform plan -target=module.kubernetes_etcd_ebs_snapshot


terraform apply -target=module.kubernetes_etcd_ebs_snapshot

```

Outputs
-------

None yet
