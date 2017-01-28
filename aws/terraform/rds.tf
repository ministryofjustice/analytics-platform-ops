# resource "aws_db_subnet_group" "main" {
#   name = "main"
#   subnet_ids = ["${aws_subnet.storage.*.id}"]
#   tags = {
#     KubernetesCluster = "${var.cluster_name}"
#     Name = "rds.${var.cluster_name}"
#   }
# }

# resource "aws_db_instance" "main" {
#   identifier           = "main-postgresql"
#   allocated_storage    = 10
#   engine               = "postgresql"
#   engine_version       = "9.6.1"
#   instance_class       = "db.t1.micro"
#   name                 = "main"
#   username             = "${var.main_db_username}"
#   password             = "${var.main_db_password}"
#   db_subnet_group_name = "${aws_db_subnet_group.main.name}"

#   tags = {
#     KubernetesCluster = "${var.cluster_name}"
#     Name = "main.rds.${var.cluster_name}"
#   }
# }
