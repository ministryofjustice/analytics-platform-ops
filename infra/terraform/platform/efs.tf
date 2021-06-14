# create the EFS filesystem
resource "aws_efs_file_system" "homedirs" {
  count = terraform.workspace == "dev" || terraform.workspace == "alpha" ? 1 : 0
  creation_token = "eks-${terraform.workspace}-user-homes"
  tags = var.tags
}

# create the access point
resource "aws_efs_access_point" "homedirs" {
  count = terraform.workspace == "dev" || terraform.workspace == "alpha" ? 1 : 0
  file_system_id = aws_efs_file_system.homedirs[0].id
}

resource "aws_security_group" "efs" {
  count = terraform.workspace == "dev" || terraform.workspace == "alpha" ? 1 : 0
  name        = "EfsSecurityGroup"
  description = "EFS security group to allow access to home directories"
  vpc_id      = data.aws_vpc.main.id
  ingress {
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = var.private_cidrs
  }
}

resource "aws_efs_mount_target" "homedirs" {
  count = terraform.workspace == "dev" || terraform.workspace == "alpha" ? length(data.aws_subnet_ids.storage.ids) : 0
  file_system_id = join("", aws_efs_file_system.homedirs.*.id)
  subnet_id = var.efs_subnet_ids[count.index]
  security_groups = [join("", aws_security_group.efs.*.id)]
}
