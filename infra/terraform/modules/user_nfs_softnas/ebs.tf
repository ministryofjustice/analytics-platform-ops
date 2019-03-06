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
  availability_zone = "${element(aws_instance.softnas.*.availability_zone, count.index)}"
  type              = "gp2"
  size              = "${var.default_volume_size}"

  count = "${var.num_instances}"

  tags {
    Name = "${var.env}-${var.name_identifier}-${count.index}-vol1"
  }
}

resource "aws_ebs_volume" "softnas_vol2" {
  availability_zone = "${element(aws_instance.softnas.*.availability_zone, count.index)}"
  type              = "gp2"
  size              = "${var.default_volume_size}"
  encrypted         = true

  count = "${var.num_instances}"

  tags {
    Name = "${var.env}-${var.name_identifier}-${count.index}-vol2"
  }
}

resource "aws_ebs_volume" "softnas_vol3" {
  availability_zone = "${element(aws_instance.softnas.*.availability_zone, count.index)}"
  type              = "gp2"
  size              = "500"

  count = "${var.num_instances}"

  tags {
    Name = "${var.env}-${var.name_identifier}-${count.index}-vol3"
  }
}

resource "aws_ebs_volume" "softnas_vol4" {
  availability_zone = "${element(aws_instance.softnas.*.availability_zone, count.index)}"
  type              = "gp2"
  size              = "500"
  encrypted         = true

  count = "${var.num_instances}"

  tags {
    Name = "${var.env}-${var.name_identifier}-${count.index}-vol4"
  }
}

resource "aws_ebs_volume" "softnas_vol5" {
  availability_zone = "${element(aws_instance.softnas.*.availability_zone, count.index)}"
  type              = "gp2"
  size              = "500"

  count = "${var.num_instances}"

  tags {
    Name = "${var.env}-${var.name_identifier}-${count.index}-vol5"
  }
}

resource "aws_volume_attachment" "softnas_vol1" {
  device_name = "/dev/sdf"
  volume_id   = "${element(aws_ebs_volume.softnas_vol1.*.id, count.index)}"
  instance_id = "${element(aws_instance.softnas.*.id, count.index)}"

  count = "${var.num_instances}"
}

resource "aws_volume_attachment" "softnas_vol2" {
  device_name = "/dev/sdg"
  volume_id   = "${element(aws_ebs_volume.softnas_vol2.*.id, count.index)}"
  instance_id = "${element(aws_instance.softnas.*.id, count.index)}"

  count = "${var.num_instances}"
}

resource "aws_volume_attachment" "softnas_vol3" {
  device_name = "/dev/sdh"
  volume_id   = "${element(aws_ebs_volume.softnas_vol3.*.id, count.index)}"
  instance_id = "${element(aws_instance.softnas.*.id, count.index)}"

  count = "${var.num_instances}"
}

resource "aws_volume_attachment" "softnas_vol4" {
  device_name = "/dev/sdi"
  volume_id   = "${element(aws_ebs_volume.softnas_vol4.*.id, count.index)}"
  instance_id = "${element(aws_instance.softnas.*.id, count.index)}"

  count = "${var.num_instances}"
}

resource "aws_volume_attachment" "softnas_vol5" {
  device_name = "/dev/sdj"
  instance_id = "${element(aws_instance.softnas.*.id, count.index)}"
  volume_id   = "${element(aws_ebs_volume.softnas_vol5.*.id, count.index)}"

  count = "${var.num_instances}"
}
