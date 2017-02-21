resource "aws_elasticsearch_domain" "logging" {
    domain_name = "${var.domain_name}"
    elasticsearch_version = "${var.es_version}"

    access_policies = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": ["${var.vpc_cidr}"]}
            }
        }
    ]
}
EOF

    snapshot_options {
        automated_snapshot_start_hour = 1
    }

    cluster_config {
        instance_type = "${var.instance_type}"
        instance_count = "${var.instance_count}"
        dedicated_master_enabled = "${var.dedicated_master_enabled}"
        dedicated_master_type = "${var.dedicated_master_type}"
        dedicated_master_count = "${var.dedicated_master_count}"
        zone_awareness_enabled = false
    }

    ebs_options {
        ebs_enabled = "${var.ebs_enabled}"
        volume_size = "${var.ebs_volume_size}"
        volume_type = "${var.ebs_volume_type}"
    }

    tags {
      Name = "${var.name}"
    }
}
