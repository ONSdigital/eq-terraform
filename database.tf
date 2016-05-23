resource "aws_security_group" "rds_access" {
  name        = "${var.env}-rds-access"
  description = "Block access to only ONS IPs"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_ip_block}"]
  }
}

resource "aws_db_subnet_group" "rds" {
    name = "eq-rds"
    description = "Our main group of subnets"
    subnet_ids = ["${aws_subnet.database-1.id}", "${aws_subnet.database-2.id}"]
    tags {
        Name = "My DB subnet group"
    }
}

resource "aws_db_instance" "database" {
  allocated_storage    = 10
  identifier           = "digitaleqrds"
  engine               = "postgres"
  engine_version       = "9.4.5"
  instance_class       = "db.m1.small"
  name                 = "digitaleqrds"
  username             = "digitaleq12345"
  password             = "digitaleq12345"
  multi_az             = true
  publicly_accessible  = false
  backup_retention_period = 7
  db_subnet_group_name = "${aws_db_subnet_group.rds.name}"
  vpc_security_group_ids  = ["${aws_security_group.rds_access.id}"]
}
