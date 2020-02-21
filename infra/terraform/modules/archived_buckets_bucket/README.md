# Archived buckets bucket

##### S3 bucket where data from archived buckets will go

Creates the S3 bucket where the data from archived buckets
will go.

Usage
-----

```hcl-terraform
module "archived_buckets_bucket" {
  source = "../modules/archived_buckets_bucket"

  name = "${terraform.workspace}-archived-buckets-data"
  logging_bucket_name = "${data.terraform_remote_state.global.s3_logs_bucket_name}"
  expiration_days = 183 # 6 months

  tags = "${var.tags}"
}
```

Parameters
-----------
| Name                                 | Type     | Description                               |
| ------------------------------------ | -------- | ----------------------------------------- |
| `name`                (**Required**) | `string` | name of the 'archived buckets' bucket |
| `logging_bucket_name` (**Required**) | `string` | name of the bucket where logging for the 'archived buckets' bucket will go |
| `tags`                (**Required**) | `map` | Tags to attach to the bucket |
| `region`              (**Required**) | `string` | Region where the S3 bucket will be created |
| `expiration_days`                    | `integer` | number of days after which the objects (and the older versions) will be deleted |
