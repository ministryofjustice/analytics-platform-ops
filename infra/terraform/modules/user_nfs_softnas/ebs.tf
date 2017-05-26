###
# See http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html for
# device naming rules
#
# With current SoftNAS default instance type (m4.large) device names should
# follow the pattern /dev/sd[f-p]
##

resource "aws_ebs_volume" "softnas_vol1" {
    availability_zone = "${element(aws_instance.softnas.*.availability_zone, count.index)}"
    type = "gp2"
    size = "${var.default_volume_size}"

    count = "${var.num_instances}"

    tags {
      Name = "${var.env}-softnas-vol1"
    }
}

resource "aws_volume_attachment" "softnas_vol1" {
  device_name = "/dev/sdf"
  volume_id   = "${element(aws_ebs_volume.softnas_vol1.*.id, count.index)}"
  instance_id = "${element(aws_instance.softnas.*.id, count.index)}"

  count = "${var.num_instances}"
}
