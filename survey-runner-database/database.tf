resource "aws_security_group" "survey_runner_rds_access" {
  name        = "${var.rds_security_group_name}"
  description = "Database access from the application subnet"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = "${var.application_cidrs}"
  }

  tags {
    Name = "${var.env}-db-security-group"
  }
}

resource "aws_db_instance" "survey_runner_database" {
  allocated_storage           = "${var.database_allocated_storage}"
  identifier                  = "${var.database_identifier}"
  engine                      = "postgres"
  engine_version              = "${var.database_engine_version}"
  allow_major_version_upgrade = "${var.allow_major_version_upgrade}"
  instance_class              = "${var.database_instance_class}"
  name                        = "${var.snapshot_identifier == "" ? var.database_name : ""}"
  username                    = "${var.database_user}"
  password                    = "${var.database_password}"
  multi_az                    = "${var.multi_az}"
  publicly_accessible         = false
  backup_retention_period     = "${var.backup_retention_period}"
  db_subnet_group_name        = "${var.db_subnet_group_name}"
  vpc_security_group_ids      = ["${aws_security_group.survey_runner_rds_access.id}"]
  storage_type                = "gp2"
  apply_immediately           = "${var.database_apply_immediately}"
  snapshot_identifier         = "${var.snapshot_identifier}"
  skip_final_snapshot         = true
  maintenance_window          = "${var.preferred_maintenance_window}"

  tags {
    Name        = "${var.env}-db-instance"
    Environment = "${var.env}"
  }
}
