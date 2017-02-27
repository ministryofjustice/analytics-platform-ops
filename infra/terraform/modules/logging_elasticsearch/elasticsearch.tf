resource "aws_elasticsearch_domain" "logging" {
    domain_name = "${var.domain_name}"
    elasticsearch_version = "${var.es_version}"

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

resource "aws_elasticsearch_domain_policy" "logging" {
  domain_name = "${aws_elasticsearch_domain.logging.domain_name}"
  access_policies = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "${aws_elasticsearch_domain.logging.arn}",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": ${jsonencode(var.ingress_ips)}
        }
      }
    }
  ]
}
EOF
}
