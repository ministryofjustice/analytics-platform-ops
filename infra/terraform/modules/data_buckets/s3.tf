resource "aws_s3_bucket" "source" {
    bucket = "${var.env}-moj-analytics-source"
    acl = "private"

    tags {
        Name = "${var.env}-moj-analytics-source"
    }
}

resource "aws_s3_bucket" "scratch" {
    bucket = "${var.env}-moj-analytics-scratch"
    acl = "private"

    tags {
        Name = "${var.env}-moj-analytics-scratch"
    }
}

resource "aws_s3_bucket" "logs" {
    bucket = "${var.env}-moj-analytics-logs"
    acl = "private"

    tags {
        Name = "${var.env}-moj-analytics-logs"
    }
}
