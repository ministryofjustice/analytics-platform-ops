resource "aws_iam_instance_profile" "softnas" {
  name = "${var.env}-softnas"
  role = "${var.softnas_role_name}"

  # workaround for AWS reporting that the instance profile has been created
  # before it actually has
  provisioner "local-exec" {
    command = "sleep 30"
  }
}
