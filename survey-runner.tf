terraform {
  backend "s3" {
    bucket = "eq-terraform-state"
    region = "eu-west-1"
  }
}

module "survey-runner-alerting" {
  source             = "./survey-runner-alerting"
  env                = "${var.env}"
  aws_access_key     = "${var.aws_access_key}"
  aws_secret_key     = "${var.aws_secret_key}"
  slack_webhook_path = "${var.slack_webhook_path}"
  slack_channel      = "eq-${var.env}-alerts"
}

module "survey-runner-on-beanstalk" {
  source                  = "./survey-runner-application"
  env                     = "${var.env}"
  aws_access_key          = "${var.aws_access_key}"
  aws_secret_key          = "${var.aws_secret_key}"
  vpc_id                  = "${module.survey-runner-vpc.vpc_id}"
  use_internal_elb        = "${var.use_internal_elb}"
  eb_instance_type        = "${var.eb_instance_type}"
  eb_min_size             = "${var.eb_min_size}"
  database_address        = "${module.survey-runner-database.database_address}"
  database_port           = "${module.survey-runner-database.database_port}"
  database_name           = "${var.database_name}"
  application_cidrs       = "${var.application_cidrs}"
  rabbitmq_ip_prime       = "${module.survey-runner-queue.rabbitmq_ip_prime}"
  rabbitmq_ip_failover    = "${module.survey-runner-queue.rabbitmq_ip_failover}"
  private_route_table_ids = "${module.survey-runner-routing.private_route_table_ids}"
  public_subnet_ids       = "${module.survey-runner-routing.public_subnet_ids}"
  ons_access_ips          = "${var.ons_access_ips}"
  google_analytics_code   = "${var.google_analytics_code}"
  certificate_arn         = "${var.certificate_arn}"
  dns_zone_name           = "${var.dns_zone_name}"
  deployment_policy       = "${var.eb_deployment_policy}"
  rolling_update_enabled  = "${var.eb_rolling_update_enabled}"
  secrets_file_name       = "${var.survey_runner_secrets_file_name}"
  respondent_account_url  = "${var.respondent_account_url}"
}

module "eq-ecs" {
  source                   = "github.com/ONSdigital/eq-terraform-ecs"
  env                      = "${var.env}"
  aws_access_key           = "${var.aws_access_key}"
  aws_secret_key           = "${var.aws_secret_key}"
  ecs_instance_type        = "${var.ecs_instance_type}"
  certificate_arn          = "${var.certificate_arn}"
  vpc_id                   = "${module.survey-runner-vpc.vpc_id}"
  public_subnet_ids        = "${module.survey-runner-routing.public_subnet_ids}"
  ecs_application_cidrs    = "${var.ecs_application_cidrs}"
  private_route_table_ids  = "${module.survey-runner-routing.private_route_table_ids}"
  ecs_cluster_min_size     = "${var.ecs_cluster_min_size}"
  auto_deploy_updated_tags = "${var.auto_deploy_updated_tags}"
  ons_access_ips           = ["${split(",", var.ons_access_ips)}"]
}

module "survey-runner-on-ecs" {
  source                  = "github.com/ONSdigital/eq-survey-runner-deploy"
  env                     = "${var.env}-new"
  aws_access_key          = "${var.aws_access_key}"
  aws_secret_key          = "${var.aws_secret_key}"
  dns_zone_name           = "${var.dns_zone_name}"
  ecs_cluster_name        = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_listener_arn    = "${module.eq-ecs.aws_alb_listener_arn}"
  s3_secrets_bucket       = "${var.survey_runner_s3_secrets_bucket}"
  database_host           = "${module.survey-runner-database.database_address}"
  database_port           = "${module.survey-runner-database.database_port}"
  database_name           = "${var.database_name}"
  rabbitmq_ip_prime       = "${module.survey-runner-queue.rabbitmq_ip_prime}"
  rabbitmq_ip_failover    = "${module.survey-runner-queue.rabbitmq_ip_failover}"
  google_analytics_code   = "${var.google_analytics_code}"
  survey_runner_min_tasks = "${var.survey_runner_min_tasks}"
  docker_registry         = "${var.survey_runner_docker_registry}"
  survey_runner_tag       = "${var.survey_runner_tag}"
  secrets_file_name       = "${var.survey_runner_secrets_file_name}"
  respondent_account_url  = "${var.respondent_account_url}"
}

module "survey-launcher-for-elastic-beanstalk" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy"
  env                    = "${var.env}"
  aws_access_key         = "${var.aws_access_key}"
  aws_secret_key         = "${var.aws_secret_key}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_listener_arn   = "${module.eq-ecs.aws_alb_listener_arn}"
  service_name           = "surveys-launch"
  listener_rule_priority = 100
  docker_registry        = "${var.survey_launcher_registry}"
  container_name         = "go-launch-a-survey"
  container_port         = 8000
  container_tag          = "${var.survey_launcher_tag}"

  container_environment_variables = <<EOF
      {
        "name": "SURVEY_RUNNER_URL",
        "value": "https://${var.env}-surveys.${var.dns_zone_name}"
      },
      {
        "name": "JWT_ENCRYPTION_KEY_PATH",
        "value": "${var.survey_launcher_jwt_encryption_key_path}"
      },
      {
        "name": "JWT_SIGNING_KEY_PATH",
        "value": "${var.survey_launcher_jwt_signing_key_path}"
      },
      {
        "name": "SECRETS_S3_BUCKET",
        "value": "${var.survey_launcher_s3_secrets_bucket}"
      }
  EOF
}

module "survey-launcher-for-ecs" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy"
  env                    = "${var.env}-new"
  aws_access_key         = "${var.aws_access_key}"
  aws_secret_key         = "${var.aws_secret_key}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_listener_arn   = "${module.eq-ecs.aws_alb_listener_arn}"
  service_name           = "surveys-launch"
  listener_rule_priority = 101
  docker_registry        = "${var.survey_launcher_registry}"
  container_name         = "go-launch-a-survey"
  container_port         = 8000
  container_tag          = "${var.survey_launcher_tag}"

  container_environment_variables = <<EOF
      {
        "name": "SURVEY_RUNNER_URL",
        "value": "https://${var.env}-new-surveys.${var.dns_zone_name}"
      },
      {
        "name": "JWT_ENCRYPTION_KEY_PATH",
        "value": "${var.survey_launcher_jwt_encryption_key_path}"
      },
      {
        "name": "JWT_SIGNING_KEY_PATH",
        "value": "${var.survey_launcher_jwt_signing_key_path}"
      },
      {
        "name": "SECRETS_S3_BUCKET",
        "value": "${var.survey_launcher_s3_secrets_bucket}"
      }
  EOF
}

module "author" {
  source                  = "github.com/ONSdigital/eq-author-deploy"
  env                     = "${var.env}"
  aws_access_key          = "${var.aws_access_key}"
  aws_secret_key          = "${var.aws_secret_key}"
  dns_zone_name           = "${var.dns_zone_name}"
  ecs_cluster_name        = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_listener_arn    = "${module.eq-ecs.aws_alb_listener_arn}"
  application_cidrs       = "${concat(var.ecs_application_cidrs, var.application_cidrs)}"
  author_tag              = "${var.author_tag}"
  author_api_tag          = "${var.author_api_tag}"
  publisher_tag           = "${var.publisher_tag}"
  survey_launcher_url     = "${module.survey-launcher-for-ecs.service_address}"
}

module "survey-runner-database" {
  source                           = "./survey-runner-database"
  env                              = "${var.env}"
  aws_access_key                   = "${var.aws_access_key}"
  aws_secret_key                   = "${var.aws_secret_key}"
  vpc_id                           = "${module.survey-runner-vpc.vpc_id}"
  application_cidrs                = "${concat(var.ecs_application_cidrs, var.application_cidrs)}"
  database_cidrs                   = "${var.database_cidrs}"
  private_route_table_ids          = "${module.survey-runner-routing.private_route_table_ids}"
  multi_az                         = "${var.multi_az}"
  backup_retention_period          = "${var.backup_retention_period}"
  database_apply_immediately       = "${var.database_apply_immediately}"
  database_instance_class          = "${var.database_instance_class}"
  database_allocated_storage       = "${var.database_allocated_storage}"
  database_free_memory_alert_level = "${var.database_free_memory_alert_level}"
  database_name                    = "${var.database_name}"
  database_user                    = "${var.database_user}"
  database_password                = "${var.database_password}"
}

module "survey-runner-queue" {
  source                       = "./survey-runner-queue"
  env                          = "${var.env}"
  aws_access_key               = "${var.aws_access_key}"
  aws_secret_key               = "${var.aws_secret_key}"
  vpc_id                       = "${module.survey-runner-vpc.vpc_id}"
  queue_cidrs                  = "${var.queue_cidrs}"
  application_cidrs            = "${concat(var.ecs_application_cidrs, var.application_cidrs)}"
  sdx_cidrs                    = "${var.sdx_cidrs}"
  audit_cidr                   = "${var.audit_cidr}"
  rsyslogd_server_ip           = "${var.rsyslogd_server_ip}"
  logserver_cidr               = "${var.logserver_cidr}"
  rabbitmq_instance_type       = "${var.rabbitmq_instance_type}"
  rabbitmq_admin_user          = "${var.rabbitmq_admin_user}"
  rabbitmq_admin_password      = "${var.rabbitmq_admin_password}"
  rabbitmq_write_user          = "${var.rabbitmq_write_user}"
  rabbitmq_write_password      = "${var.rabbitmq_write_password}"
  rabbitmq_read_user           = "${var.rabbitmq_read_user}"
  rabbitmq_read_password       = "${var.rabbitmq_read_password}"
  dns_zone_name                = "${var.dns_zone_name}"
  aws_key_pair                 = "${var.aws_key_pair}"
  internet_gateway_id          = "${module.survey-runner-vpc.internet_gateway_id}"
  ebs_snapshot_retention_days  = "${var.rabbitmq_ebs_snapshot_retention_days}"
  delete_volume_on_termination = "${var.rabbitmq_delete_volume_on_termination}"
}

module "survey-runner-routing" {
  source              = "./survey-runner-routing"
  env                 = "${var.env}"
  aws_access_key      = "${var.aws_access_key}"
  aws_secret_key      = "${var.aws_secret_key}"
  public_cidrs        = "${var.public_cidrs}"
  vpc_id              = "${module.survey-runner-vpc.vpc_id}"
  internet_gateway_id = "${module.survey-runner-vpc.internet_gateway_id}"
}

module "survey-runner-vpc" {
  source         = "./survey-runner-vpc"
  env            = "${var.env}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
}

output "survey_runner_beanstalk" {
  value = "${module.survey-runner-on-beanstalk.survey_runner_elb_address}"
}

output "survey_launcher_for_beanstalk" {
  value = "${module.survey-launcher-for-elastic-beanstalk.service_address}"
}

output "survey_runner_ecs" {
  value = "${module.survey-runner-on-ecs.survey_runner_address}"
}

output "survey_launcher_for_ecs" {
  value = "${module.survey-launcher-for-ecs.service_address}"
}

output "author_address" {
  value = "${module.author.author_address}"
}