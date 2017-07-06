module "survey-runner-alerting" {
  source = "./survey-runner-alerting"
  env = "${var.env}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  slack_webhook_path = "${var.slack_webhook_path}"
}

module "survey-runner-application" {
  source = "./survey-runner-application"
  env = "${var.env}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  vpc_id = "${module.survey-runner-vpc.vpc_id}"
  database_address = "${module.survey-runner-database.database_address}"
  database_port = "${module.survey-runner-database.database_port}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
  application_cidrs = "${var.application_cidrs}"
  rabbitmq_ip_prime = "${module.survey-runner-queue.rabbitmq_ip_prime}"
  rabbitmq_ip_failover = "${module.survey-runner-queue.rabbitmq_ip_failover}"
  private_route_table_ids = "${module.survey-runner-routing.private_route_table_ids}"
  public_subnet_ids = "${module.survey-runner-routing.public_subnet_ids}"
  ons_access_ips = "${var.ons_access_ips}"
  google_analytics_code = "${var.google_analytics_code}"
  certificate_arn = "${var.certificate_arn}"
  application_secret_key = "${var.application_secret_key}"
  rabbitmq_admin_user = "${var.rabbitmq_admin_user}"
  rabbitmq_admin_password = "${var.rabbitmq_admin_password}"
  rabbitmq_write_user = "${var.rabbitmq_write_user}"
  rabbitmq_write_password = "${var.rabbitmq_write_password}"
  rabbitmq_read_user = "${var.rabbitmq_read_user}"
  rabbitmq_read_password = "${var.rabbitmq_read_password}"
  dns_zone_id = "${var.dns_zone_id}"
  dns_zone_name = "${var.dns_zone_name}"
  deployment_policy = "${var.eb_deployment_policy}"
  rolling_update_enabled = "${var.eb_rolling_update_enabled}"
}

module "survey-runner-ecs" {
  source = "github.com/ONSdigital/eq-terraform-ecs"
  env = "${var.env}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  dns_zone_id = "${var.dns_zone_id}"
  dns_zone_name = "${var.dns_zone_name}"
  certificate_arn = "${var.certificate_arn}"
  vpc_id = "${module.survey-runner-vpc.vpc_id}"
  public_subnet_ids = "${module.survey-runner-routing.public_subnet_ids}"
  ecs_application_cidrs = "${var.ecs_application_cidrs}"
  private_route_table_ids = "${module.survey-runner-routing.private_route_table_ids}"
  survey_runner_url = "https://${var.env}-surveys.${var.dns_zone_name}"
  s3_secrets_bucket = "${var.survey_launcher_s3_secrets_bucket}"
  jwt_signing_key_path = "${var.survey_launcher_jwt_signing_key_path}"
  jwt_encryption_key_path = "${var.survey_launcher_jwt_encryption_key_path}"
}

module "survey-runner-database" {
  source = "./survey-runner-database"
  env = "${var.env}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  vpc_id = "${module.survey-runner-vpc.vpc_id}"
  application_cidrs = "${var.application_cidrs}"
  database_cidrs = "${var.database_cidrs}"
  private_route_table_ids = "${module.survey-runner-routing.private_route_table_ids}"
  multi_az = "${var.multi_az}"
  backup_retention_period = "${var.backup_retention_period}"
}

module "survey-runner-queue" {
  source = "./survey-runner-queue"
  env = "${var.env}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  vpc_id = "${module.survey-runner-vpc.vpc_id}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
  queue_cidrs = "${var.queue_cidrs}"
  application_cidrs = "${var.application_cidrs}"
  sdx_cidrs = "${var.sdx_cidrs}"
  audit_cidr = "${var.audit_cidr}"
  rsyslogd_server_ip = "${var.rsyslogd_server_ip}"
  logserver_cidr = "${var.logserver_cidr}"
  rabbitmq_admin_user = "${var.rabbitmq_admin_user}"
  rabbitmq_admin_password = "${var.rabbitmq_admin_password}"
  rabbitmq_write_user = "${var.rabbitmq_write_user}"
  rabbitmq_write_password = "${var.rabbitmq_write_password}"
  rabbitmq_read_user = "${var.rabbitmq_read_user}"
  rabbitmq_read_password = "${var.rabbitmq_read_password}"
  dns_zone_id = "${var.dns_zone_id}"
  dns_zone_name = "${var.dns_zone_name}"
  aws_key_pair = "${var.aws_key_pair}"
  internet_gateway_id = "${module.survey-runner-vpc.internet_gateway_id}"
}

module "survey-runner-routing" {
  source = "./survey-runner-routing"
  env = "${var.env}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  public_cidrs = "${var.public_cidrs}"
  vpc_id = "${module.survey-runner-vpc.vpc_id}"
  internet_gateway_id = "${module.survey-runner-vpc.internet_gateway_id}"
}

module "survey-runner-vpc" {
  source = "./survey-runner-vpc"
  env = "${var.env}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
}

output "survey_runner_address" {
  value = "${module.survey-runner-application.survey_runner_elb_address}"
}

output "survey_runner_launcher_address" {
  value = "${module.survey-runner-ecs.survey_runner_launcher_address}"
}