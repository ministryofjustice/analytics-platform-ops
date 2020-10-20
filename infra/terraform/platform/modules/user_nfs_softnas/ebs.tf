### IMPORTANT NOTE
# The following volume definitions include volumes that were provisioned outside
# of Terraform via the SoftNAS GUI. Sizes differ (2.x250GB, 2x500GB), and two
# volumes have encryption enabled, and two don't. This is not ideal, but as
# SoftNAS is likely to be replaced with an alternative product the as-is
# infrastructure config has been captured here for now.

###
# See http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html for
# device naming rules
#
# With current SoftNAS default instance type (m4.large) device names should
# follow the pattern /dev/sd[f-p]
##

resource "aws_ebs_volume" "softnas_vol1" {
  availability_zone = element(aws_instance.softnas.*.availability_zone, count.index)
  type              = "gp2"
  size              = var.default_volume_size

  count = var.num_instances

  tags = merge(
    {
      "Name" = "${terraform.workspace}-${var.name_identifier}-${count.index}-vol1"
    },
    var.tags,
  )
}

resource "aws_ebs_volume" "softnas_vol2" {
  availability_zone = element(aws_instance.softnas.*.availability_zone, count.index)
  type              = "gp2"
  size              = var.default_volume_size
  encrypted         = true

  count = var.num_instances

  tags = merge(
    {
      "Name" = "${terraform.workspace}-${var.name_identifier}-${count.index}-vol2"
    },
    var.tags,
  )
}

resource "aws_ebs_volume" "softnas_vol3" {
  availability_zone = element(aws_instance.softnas.*.availability_zone, count.index)
  type              = "gp2"
  size              = "500"

  count = var.num_instances

  tags = merge(
    {
      "Name" = "${terraform.workspace}-${var.name_identifier}-${count.index}-vol3"
    },
    var.tags,
  )
}

resource "aws_ebs_volume" "softnas_vol4" {
  availability_zone = element(aws_instance.softnas.*.availability_zone, count.index)
  type              = "gp2"
  size              = "500"
  encrypted         = true

  count = var.num_instances

  tags = merge(
    {
      "Name" = "${terraform.workspace}-${var.name_identifier}-${count.index}-vol4"
    },
    var.tags,
  )
}

resource "aws_ebs_volume" "softnas_vol5" {
  availability_zone = element(aws_instance.softnas.*.availability_zone, count.index)
  type              = "gp2"
  size              = "500"

  count = var.num_instances

  tags = merge(
    {
      "Name" = "${terraform.workspace}-${var.name_identifier}-${count.index}-vol5"
    },
    var.tags,
  )
}

resource "aws_ebs_volume" "softnas_vol6" {
  # production-only volume
  count = var.is_production ? var.num_instances : 0

  availability_zone = element(
    concat(aws_instance.softnas.*.availability_zone, [""]),
    count.index,
  )
  type = "gp2"
  size = "1024"

  tags = merge(
    {
      "Name" = "${terraform.workspace}-${var.name_identifier}-${count.index}-vol6"
    },
    var.tags,
  )
}

# Created EBS volume only for `softnas-1` in AWS Console - that's why the
# SoftNAS instance is hardcoded to `.1` and it's a production-only volume
resource "aws_ebs_volume" "softnas_1_vol7" {
  # production-only volume
  count = var.is_production ? 1 : 0

  availability_zone = aws_instance.softnas[1].availability_zone
  type              = "gp2"
  size              = "2048"
  encrypted         = true

  tags = merge(
    {
      "Name" = "${terraform.workspace}-${var.name_identifier}-1-vol7"
    },
    var.tags,
  )
}

resource "aws_volume_attachment" "softnas_vol1" {
  device_name = "/dev/sdf"
  volume_id   = element(aws_ebs_volume.softnas_vol1.*.id, count.index)
  instance_id = element(aws_instance.softnas.*.id, count.index)

  count = var.num_instances
}

resource "aws_volume_attachment" "softnas_vol2" {
  device_name = "/dev/sdg"
  volume_id   = element(aws_ebs_volume.softnas_vol2.*.id, count.index)
  instance_id = element(aws_instance.softnas.*.id, count.index)

  count = var.num_instances
}

resource "aws_volume_attachment" "softnas_vol3" {
  device_name = "/dev/sdh"
  volume_id   = element(aws_ebs_volume.softnas_vol3.*.id, count.index)
  instance_id = element(aws_instance.softnas.*.id, count.index)

  count = var.num_instances
}

resource "aws_volume_attachment" "softnas_vol4" {
  device_name = "/dev/sdi"
  volume_id   = element(aws_ebs_volume.softnas_vol4.*.id, count.index)
  instance_id = element(aws_instance.softnas.*.id, count.index)

  count = var.num_instances
}

resource "aws_volume_attachment" "softnas_vol5" {
  device_name = "/dev/sdj"
  instance_id = element(aws_instance.softnas.*.id, count.index)
  volume_id   = element(aws_ebs_volume.softnas_vol5.*.id, count.index)

  count = var.num_instances
}

resource "aws_volume_attachment" "softnas_vol6" {
  # production-only volume
  count = var.is_production ? var.num_instances : 0

  device_name = "/dev/sdk"
  instance_id = element(concat(aws_instance.softnas.*.id, [""]), count.index)
  volume_id   = element(concat(aws_ebs_volume.softnas_vol6.*.id, [""]), count.index)
}

# Created EBS volume only for `softnas-1` in AWS Console - that's why the
# SoftNAS instance is hardcoded to `.1` and it's a production-only volume
resource "aws_volume_attachment" "softnas_1_vol7" {
  # production-only volume
  count = var.is_production ? 1 : 0

  device_name = "/dev/sdl"
  instance_id = aws_instance.softnas[1].id
  volume_id   = aws_ebs_volume.softnas_1_vol7[0].id
}

