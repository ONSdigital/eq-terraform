module "ebs_bckup" {
  source = "github.com/kgorskowski/ebs_bckup?ref=b08b842cac687af3dda4ccfc342bc4c2c0c692e5"
  EC2_INSTANCE_TAG = "${var.env}-RabbitMQ"
  RETENTION_DAYS   = "${var.ebs_snapshot_retention_days}"
  unique_name      = "rabbitmq_ebs_snapshot"
  stack_prefix     = "${var.env}"
  cron_expression  = "${var.ebs_snapshot_cron}"
  regions          = ["${var.aws_default_region}"]
}
