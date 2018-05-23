data "aws_ami" "ubuntu_xenial" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["*ubuntu-xenial-16.04-amd64-server*"]
  }

  filter {
    name   = "owner-id"
    values = ["099720109477"] # Canonical
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
