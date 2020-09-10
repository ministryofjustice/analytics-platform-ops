# Lambda Management

Used to provision lambda functions

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 0.12 |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | n/a     |

## Inputs

| Name                   | Description                                                                                                                            | Type          | Default         | Required |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ------------- | --------------- | :------: |
| enabled                | (optional) Boolean expression. If false, the lambda function and the cloudwatch schedule are not set.                                  | `bool`        | `true`          |    no    |
| environment\_variables | (optional) The environment variables for you lambda function                                                                           | `map(string)` | `{}`            |    no    |
| handler                | The entrypoint into your Lambda function, in the form of `filename.function_name`. For `Golang` this must match `lambda_function_name` | `string`      | n/a             |   yes    |
| lambda\_function\_name | The default name of all resources                                                                                                      | `string`      | n/a             |   yes    |
| lambda\_runtime        | Runtime language for lambda function.                                                                                                  | `string`      | `"go1.x"`       |    no    |
| lamda\_policy          | The IAM policy document to attach to the lambda                                                                                        | `string`      | n/a             |   yes    |
| schedule\_expression   | A valid rate or cron expression                                                                                                        | `string`      | `"rate(1 day)"` |    no    |
| source\_code\_hash     | The base64 encoded sha256 hash of the archive file                                                                                     | `string`      | n/a             |   yes    |
| timeout                | (optional) The amount of time your Lambda Function has to run in seconds. Defaults to 3                                                | `number`      | `3`             |    no    |
| zipfile                | Path to zip file containing code                                                                                                       | `string`      | n/a             |   yes    |

## Outputs

No output

## Usage

The example below provisions a lambda function that manages EBS snapshots

```hcl
variable "environment_variables" {
  type = "map"

  default = {
    "TAG_KEY"            = "etcd"
    "TAG_VALUE"          = "1"
    "INSTANCE_TAG_KEY"   = "k8s.io/role/master"
    "INSTANCE_TAG_VALUE" = "1"
  }
}

data "template_file" "lambda_create_snapshot_policy" {
  template = file("assets/create_etcd_ebs_snapshot/lambda_create_snapshot_policy.json")
}

data "archive_file" "kubernetes_etcd_ebs_snapshot_code" {
  source_file = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot"
  output_path = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot.zip"
  type        = "zip"
}

module "kubernetes_etcd_ebs_snapshot" {
  source                = "../modules/lambda_mgmt"
  lambda_function_name  = "create_etcd_ebs_snapshot"
  zipfile               = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot.zip"
  handler               = "create_etcd_ebs_snapshot"
  source_code_hash      = data.archive_file.kubernetes_etcd_ebs_snapshot_code.output_base64sha256
  lamda_policy          = data.template_file.lambda_create_snapshot_policy.rendered
  environment_variables = var.environment_variables
}
```
