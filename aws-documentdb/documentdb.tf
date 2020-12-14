resource "aws_security_group" "database_access" {
  name        = "${var.documentdb_security_group_name}"
  description = "Database access from the application subnet"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = "${var.application_cidrs}"
  }

  tags {
    Name = "${var.documentdb_security_group_name}"
  }
}

resource "aws_docdb_cluster_parameter_group" "paramter_group" {
  family      = "docdb4.0"
  name        = "${var.env}-paramter-group"
  description = "docdb cluster parameter group"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${var.env}-${var.documentdb_cluster_name}-cluster"
  availability_zones      = "${var.availability_zones}"
  engine                  = "docdb"
  engine_version          = "4.0.0"
  master_username         = "${var.master_username}" 
  master_password         = "${var.master_password}" 
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_subnet_group_name    = "${var.documentdb_subnet_group_name}"
  vpc_security_group_ids  = ["${aws_security_group.database_access.id}"]
  db_cluster_parameter_group_name = "${aws_docdb_cluster_parameter_group.paramter_group.name}"
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 3
  identifier         = "${var.env}-${var.documentdb_cluster_name}-cluster-instance-${count.index}"
  cluster_identifier = "${aws_docdb_cluster.docdb.id}"
  instance_class     = "${var.documentdb_instance_size}"
}
