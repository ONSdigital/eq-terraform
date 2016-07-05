resource "aws_security_group" "author_rds_access" {
  name        = "${var.env}-rds-access"
  description = "Allow access to the database from the default vpc"
  vpc_id      = "${aws_vpc.author-vpc.id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_ip_block}"]
  }
  tags {
    Name = "${var.env}-author-db-security-group"
  }
}

resource "aws_db_subnet_group" "author_rds" {
    name = "${var.env}-eq-author-rds"
    description = "The two database subnets"
    subnet_ids = ["${aws_subnet.database-1b.id}", "${aws_subnet.database-1c.id}"]
    tags {
        Name = "${var.env}-author-db-subnet"
    }
}

resource "aws_db_instance" "author-database" {
  allocated_storage    = 10
  identifier           = "${var.env}-authoreqrds"
  engine               = "postgres"
  engine_version       = "9.4.5"
  instance_class       = "db.m1.small"
  name                 = "${var.database_name}"
  username             = "${var.database_user}"
  password             = "${var.database_password}"
  multi_az             = true
  publicly_accessible  = false
  backup_retention_period = 7
  db_subnet_group_name = "${aws_db_subnet_group.author_rds.name}"
  vpc_security_group_ids  = ["${aws_security_group.author_rds_access.id}"]
  tags {
        Name = "${var.env}-author-db"
  }
}
