resource "aws_rds_cluster" "default" {
  cluster_identifier = "aurora-cluster-demo"
  availability_zones = ["${var.aws_default_region}"]
  database_name = "mydb"
  master_username = "foo"
  master_password = "bar"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
}