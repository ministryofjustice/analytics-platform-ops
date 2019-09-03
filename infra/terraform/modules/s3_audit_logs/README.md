# Audit S3 Bucket IAM policy

Terraform Module to create an instance IAM policy allowing ec2 instances to write to audit log S3 bucket

### Variables

| Variable  | Description      | Default |
| ---------- | ---------------  | ------- |
| `policy_name`     | Name of the instance policy you want to create|   ""  |
| `instance_role_name` | The Instance Role to attach the policy to | "" |



### Usage

```
module "s3_audit_logs_policy_attachment" {
  source             = "../modules/s3_audit_logs"
  policy_name        = "${terraform.workspace}-s3-audit-logs"
  instance_role_name = ["${var.instance_role_name}"]
}
```
