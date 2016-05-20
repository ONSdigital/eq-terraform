resource "aws_db_instance" "db1" {
  allocated_storage    = 10
  identifier           = "digitaleqrds1"
  engine               = "postgres"
  engine_version       = "9.4.5"
  instance_class       = "db.m1.small"
  name                 = "digitaleqrds"
  username             = "digitaleq12345"
  password             = "digitaleq12345"
  multi_az             = true
  backup_retention_period = 7
}

resource "aws_db_instance" "db2" {
  allocated_storage    = 10
  identifier           = "digitaleqrds2"
  engine               = "postgres"
  engine_version       = "9.4.5"
  instance_class       = "db.m1.small"
  name                 = "digitaleqrds"
  username             = "digitaleq12345"
  password             = "digitaleq12345"
  multi_az             = true
  replicate_source_db  = "${aws_db_instance.db1.identifier}"
  backup_retention_period = 7
}