# Buckets Archiver

##### S3 bucket where data from archived buckets will go

Creates the S3 bucket where the data from archived buckets
will go and IAM role to archive this data.

Usage
-----

```hcl-terraform
module "buckets_archiver" {
  source = "../modules/buckets_archiver"

  env = "${terraform.workspace}"
  name = "${terraform.workspace}-archived-buckets-data"
  logging_bucket_name = "${data.terraform_remote_state.global.s3_logs_bucket_name}"
  expiration_days = 183 # 6 months
  k8s_worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${terraform.workspace}.${data.terraform_remote_state.global.platform_root_domain}"

  tags = "${var.tags}"
}
```

Parameters
-----------
| Name                                 | Type     | Description                               |
| ------------------------------------ | -------- | ----------------------------------------- |
| `env`                 (**Required**) | `string` | environment name |
| `name`                (**Required**) | `string` | name of the 'archived buckets' bucket |
| `logging_bucket_name` (**Required**) | `string` | name of the bucket where logging for the 'archived buckets' bucket will go |
| `tags`                (**Required**) | `map` | Tags to attach to the bucket |
| `region`              (**Required**) | `string` | Region where the S3 bucket will be created |
| `k8s_worker_role_arn` (**Required**) | `string` | ARN of the IAM role of the kubernetes workers. Used to allow them to assume 'buckets_archiver' role |
| `expiration_days`                    | `integer` | number of days after which the objects (and the older versions) will be deleted |
