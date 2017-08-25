resource "aws_db_instance" "control_panel_db" {
    storage_type = "${var.storage_type}"
    allocated_storage = "${var.allocated_storage}"
    engine = "postgres"
    engine_version = "9.6.2"
    instance_class = "db.t2.micro"
    name = "controlpanel"
    username = "controlpanel"
    password = "controlpanel"
    db_subnet_group_name = "${var.env}-control-panel-db"
}
