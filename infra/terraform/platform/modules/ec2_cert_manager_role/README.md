# EC2 Cert-Manager IAM Role

Terraform Module to create an instance role allowing [Cert-Manager](https://github.com/jetstack/cert-manager) to perform [DNS01](https://cert-manager.readthedocs.io/en/latest/tutorials/acme/dns-validation.html) challenge

### Variables

| Variable  | Description      | Default |
| ---------- | ---------------  | ------- |
| `role_name`     | Name of the instance role you want to create|   ""  |
| `trusted_entity` | Trusted entity ARN to assume the instance role | "" |
| `hostedzoneid_arn` | ARN of the hosted zone to perform the DNS01 challenge | "" |


See: [DNS01 Challenge](https://docs.certifytheweb.com/docs/dns-validation.html) for more information on DNS validation  

Required IAM configuration for this process is detailed [here](https://cert-manager.readthedocs.io/en/latest/reference/issuers/acme/dns01.html#amazon-route53) 

### Usage

```
module "cert_manager" {
  source             = "../modules/ec2_cert_manager_role"
  role_name          = "${var.role_name}"
  trusted_entity     = ["${var.trusted_entity}"]
  hostedzoneid_arn   = ["${var.hostedzoneid_arn}"]
}

```
