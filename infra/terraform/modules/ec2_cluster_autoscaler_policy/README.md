# EC2 Cluster-AutoScaler IAM policy

Terraform Module to create an instance IAM policy allowing [Cluster_AutoScaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) to perform operations on Kubernetes nodes autoscaling groups 

### Variables

| Variable  | Description      | Default |
| ---------- | ---------------  | ------- |
| `policy_name`     | Name of the instance policy you want to create|   ""  |
| `instance_role_name` | The Instance Role to attach the policy to | "" |
| `asg_arn` | ARN of the autoscaling group the Kubernetes worker nodes belong to | "" |


Required IAM permissions for this process is detailed [here](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#permissions) 

### Usage

```
module "cluster_autoscaler_policy_attachment" {
  source             = "../modules/ec2_cluster_autoscaler_policy"
  policy_name        = "${terraform.workspace}-cluster-autoscaler"
  instance_role_name = ["${var.instance_role_name}"]
  asg_arn            = ["${var.asg_arn}"]
}

```
