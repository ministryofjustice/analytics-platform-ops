resource "aws_elasticache_replication_group" "control_panel_redis" {
  replication_group_id          = "${terraform.workspace}-control-panel-redis"
  replication_group_description = "${terraform.workspace} CP Redis cluster"

  engine         = "redis"
  engine_version = var.redis_engine_version
  port           = var.redis_port
  auth_token     = var.redis_password

  automatic_failover_enabled = true
  availability_zones         = var.availability_zones
  node_type                  = var.redis_node_type
  number_cache_clusters      = 3

  subnet_group_name          = aws_elasticache_subnet_group.control_panel_redis.name
  security_group_ids         = [aws_security_group.control_panel_redis.id]
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = var.tags
}

resource "aws_security_group" "control_panel_redis" {
  name   = "${terraform.workspace}-control-panel-redis"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.redis_port
    to_port         = var.redis_port
    protocol        = "tcp"
    security_groups = var.ingress_security_group_ids
  }

  tags = var.tags
}

resource "aws_elasticache_subnet_group" "control_panel_redis" {
  name       = "${terraform.workspace}-control-panel-redis"
  subnet_ids = var.db_subnet_ids
}

