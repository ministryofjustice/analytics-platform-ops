resource "aws_s3_bucket" "moj-analytics-source" {
    bucket = "moj-analytics-source-${var.region}"
    acl = "private"

    tags {
        Name = "moj-analytics-source-${var.region}"
    }
}

resource "aws_s3_bucket" "moj-analytics-scratch" {
    bucket = "moj-analytics-scratch-${var.region}"
    acl = "private"

    tags {
        Name = "moj-analytics-scratch-${var.region}"
    }
}

resource "aws_s3_bucket" "moj-analytics-logs" {
    bucket = "moj-analytics-logs-${var.region}"
    acl = "private"

    tags {
        Name = "moj-analytics-logs-${var.region}"
    }
}


output "s3-analytics-source-arn" {
    value = "${aws_s3_bucket.moj-analytics-source.arn}"
}

output "s3-analytics-scratch-arn" {
    value = "${aws_s3_bucket.moj-analytics-source.arn}"
}

output "s3-analytics-logs-arn" {
    value = "${aws_s3_bucket.moj-analytics-source.arn}"
}
