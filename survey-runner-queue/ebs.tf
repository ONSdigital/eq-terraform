module "ebs_bckup" {
  source = "github.com/ONSdigital/ebs_bckup?ref=f9b4e8272fe23a6ec30f40755a349e5f0f83c17d"
  EC2_INSTANCE_TAG = "${var.env}-RabbitMQ"
  RETENTION_DAYS   = "${var.ebs_snapshot_retention_days}"
  unique_name      = "rabbitmq_ebs_snapshot"
  stack_prefix     = "${var.env}"
  cron_expression  = "${var.ebs_snapshot_cron}"
  regions          = ["${var.aws_default_region}"]
}
