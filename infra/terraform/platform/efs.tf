# create the EFS filesystem
resource "aws_efs_file_system" "homedirs" {
  count = terraform.workspace == "dev" ? 1 : 0
  creation_token = "eks-${terraform.workspace}-user-homes"
  tags = local.tags
}

# create the access point
resource "aws_efs_access_point" "homedirs" {
  count = terraform.workspace == "dev" ? 1 : 0
  file_system_id = aws_efs_file_system.homedirs[0].id
}

resource "aws_security_group" "efs" {
  count = terraform.workspace == "dev" ? 1 : 0
  name        = "MyEfsSecurityGroup"
  description = "EFS security group to allow access to home directories"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = local.account.private_subnets
  }
}

resource "aws_efs_mount_target" "homedirs" {
  count = terraform.workspace == "dev" ? length(module.vpc.private_subnets) : 0
  file_system_id = join("", aws_efs_file_system.homedirs.*.id)
  subnet_id = module.vpc.private_subnets[count.index]
  security_groups = [join("", aws_security_group.efs.*.id)]
}
