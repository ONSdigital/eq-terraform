terraform {
  required_version = ">= 0.10.0, < 0.11.0"

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
  source                         = "./survey-runner-application"
  env                            = "${var.env}"
  aws_access_key                 = "${var.aws_access_key}"
  aws_secret_key                 = "${var.aws_secret_key}"
  vpc_id                         = "${module.survey-runner-vpc.vpc_id}"
  use_internal_elb               = "${var.use_internal_elb}"
  eb_instance_type               = "${var.eb_instance_type}"
  eb_min_size                    = "${var.eb_min_size}"
  database_address               = "${module.survey-runner-database.database_address}"
  database_port                  = "${module.survey-runner-database.database_port}"
  database_name                  = "${var.database_name}"
  application_cidrs              = "${var.application_cidrs}"
  rabbitmq_ip_prime              = "${module.survey-runner-queue.rabbitmq_ip_prime}"
  rabbitmq_ip_failover           = "${module.survey-runner-queue.rabbitmq_ip_failover}"
  private_route_table_ids        = "${module.survey-runner-routing.private_route_table_ids}"
  public_subnet_ids              = "${module.survey-runner-routing.public_subnet_ids}"
  ons_access_ips                 = "${var.ons_access_ips}"
  google_analytics_code          = "${var.google_analytics_code}"
  certificate_arn                = "${var.certificate_arn}"
  dns_zone_name                  = "${var.dns_zone_name}"
  deployment_policy              = "${var.eb_deployment_policy}"
  rolling_update_enabled         = "${var.eb_rolling_update_enabled}"
  secrets_file_name              = "${var.survey_runner_secrets_file_name}"
  respondent_account_url         = "${var.respondent_account_url}"
  submitted_responses_table_name = "${module.survey-runner-dynamodb.submitted_responses_table_name}"
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
  eq_gateway_ips           = ["${module.survey-runner-routing.nat_gateway_ips}"]
}

module "survey-runner-on-ecs" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v1.4.0"
  env                    = "${var.env}-new"
  aws_access_key         = "${var.aws_access_key}"
  aws_secret_key         = "${var.aws_secret_key}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn            = "${module.eq-ecs.aws_alb_arn}"
  service_name           = "surveys"
  listener_rule_priority = 10
  docker_registry        = "${var.survey_runner_docker_registry}"
  container_name         = "eq-survey-runner"
  container_port         = 5000
  healthcheck_path       = "/status"
  container_tag          = "${var.survey_runner_tag}"
  application_min_tasks  = "${var.survey_runner_min_tasks}"
  slack_alert_sns_arn    = "${module.survey-runner-alerting.slack_alert_sns_arn}"

  container_environment_variables = <<EOF
      {
        "name": "EQ_RABBITMQ_HOST",
        "value": "${module.survey-runner-queue.rabbitmq_ip_prime}"
      },
      {
        "name": "EQ_RABBITMQ_HOST_SECONDARY",
        "value": "${module.survey-runner-queue.rabbitmq_ip_failover}"
      },
      {
        "name": "EQ_RABBITMQ_QUEUE_NAME",
        "value": "${var.survey_runner_message_queue_name}"
      },
      {
        "name": "EQ_SERVER_SIDE_STORAGE_DATABASE_HOST",
        "value": "${module.survey-runner-database.database_address}"
      },
      {
        "name": "EQ_SERVER_SIDE_STORAGE_DATABASE_PORT",
        "value": "${module.survey-runner-database.database_port}"
      },
      {
        "name": "EQ_SERVER_SIDE_STORAGE_DATABASE_NAME",
        "value": "${var.database_name}"
      },
      {
        "name": "EQ_LOG_LEVEL",
        "value": "${var.survey_runner_log_level}"
      },
      {
        "name": "EQ_UA_ID",
        "value": "${var.google_analytics_code}"
      },
      {
        "name": "SECRETS_S3_BUCKET",
        "value": "${var.survey_runner_s3_secrets_bucket}"
      },
      {
        "name": "EQ_SECRETS_FILE",
        "value": "${var.survey_runner_secrets_file_name}"
      },
      {
        "name": "EQ_KEYS_FILE",
        "value": "${var.survey_runner_keys_file_name}"
      },
      {
        "name": "RESPONDENT_ACCOUNT_URL",
        "value": "${var.respondent_account_url}"
      },
      {
        "name": "EQ_SUBMITTED_RESPONSES_TABLE_NAME",
        "value": "${module.survey-runner-dynamodb.submitted_responses_table_name}"
      },
      {
        "name": "EQ_NEW_RELIC_ENABLED",
        "value": "${var.survey_runner_new_relic_enabled}"
      },
      {
        "name": "NEW_RELIC_APP_NAME",
        "value": "${var.survey_runner_new_relic_app_name}"
      },
      {
        "name": "NEW_RELIC_LICENSE_KEY",
        "value": "${var.survey_runner_new_relic_licence_key}"
      }
  EOF

  task_has_iam_policy = true
  task_iam_policy_json = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "",
          "Effect": "Allow",
          "Action": [
              "s3:ListObjects",
              "s3:ListBucket",
              "s3:GetObject"
          ],
          "Resource": "arn:aws:s3:::*"
      },
      {
          "Sid": "",
          "Effect": "Allow",
          "Action": [
              "dynamodb:PutItem",
              "dynamodb:GetItem"
          ],
          "Resource": "${module.survey-runner-dynamodb.submitted_responses_table_arn}"
      }
  ]
}
  EOF
}

module "survey-runner-static-on-ecs" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v1.4.0"
  env                    = "${var.env}-new"
  aws_access_key         = "${var.aws_access_key}"
  aws_secret_key         = "${var.aws_secret_key}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name          = "${var.dns_zone_name}"
  dns_record_name        = "${var.env}-new-surveys.${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn            = "${module.eq-ecs.aws_alb_arn}"
  service_name           = "surveys-static"
  listener_rule_priority = 5
  docker_registry        = "${var.survey_runner_docker_registry}"
  container_name         = "eq-survey-runner-static"
  container_port         = 80
  container_tag          = "${var.survey_runner_tag}"
  application_min_tasks  = "${var.survey_runner_min_tasks}"
  slack_alert_sns_arn    = "${module.survey-runner-alerting.slack_alert_sns_arn}"
  alb_listener_path_pattern = "/s/*"
}

module "survey-launcher-for-elastic-beanstalk" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v1.4.0"
  env                    = "${var.env}"
  aws_access_key         = "${var.aws_access_key}"
  aws_secret_key         = "${var.aws_secret_key}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn            = "${module.eq-ecs.aws_alb_arn}"
  service_name           = "surveys-launch"
  listener_rule_priority = 100
  docker_registry        = "${var.survey_launcher_registry}"
  container_name         = "go-launch-a-survey"
  container_port         = 8000
  container_tag          = "${var.survey_launcher_tag}"
  application_min_tasks  = "${var.survey_launcher_min_tasks}"
  slack_alert_sns_arn    = "${module.survey-runner-alerting.slack_alert_sns_arn}"

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
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v1.4.0"
  env                    = "${var.env}-new"
  aws_access_key         = "${var.aws_access_key}"
  aws_secret_key         = "${var.aws_secret_key}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn            = "${module.eq-ecs.aws_alb_arn}"
  service_name           = "surveys-launch"
  listener_rule_priority = 15
  docker_registry        = "${var.survey_launcher_registry}"
  container_name         = "go-launch-a-survey"
  container_port         = 8000
  container_tag          = "${var.survey_launcher_tag}"
  application_min_tasks  = "${var.survey_launcher_min_tasks}"
  slack_alert_sns_arn    = "${module.survey-runner-alerting.slack_alert_sns_arn}"

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
  source                           = "github.com/ONSdigital/eq-ecs-deploy?ref=v1.4.0"
  env                              = "${var.env}"
  aws_access_key                   = "${var.aws_access_key}"
  aws_secret_key                   = "${var.aws_secret_key}"
  dns_zone_name                    = "${var.dns_zone_name}"
  ecs_cluster_name                 = "${module.eq-ecs.ecs_cluster_name}"
  vpc_id                           = "${module.survey-runner-vpc.vpc_id}"
  aws_alb_arn                      = "${module.eq-ecs.aws_alb_arn}"
  service_name                     = "author"
  listener_rule_priority           = 102
  docker_registry                  = "${var.author_registry}"
  container_name                   = "eq-author"
  container_port                   = 3000
  container_tag                    = "${var.author_tag}"
  healthcheck_path                 = "/status.json"
  healthcheck_grace_period_seconds = 60
  slack_alert_sns_arn              = "${module.survey-runner-alerting.slack_alert_sns_arn}"
  application_min_tasks            = "${var.author_min_tasks}"
  high_cpu_threshold               = 80

  container_environment_variables = <<EOF
      {
        "name": "REACT_APP_BASE_NAME",
        "value": "/eq-author"
      },
      {
        "name": "REACT_APP_USE_MOCK_API",
        "value": "false"
      },
      {
        "name": "REACT_APP_API_URL",
        "value": "${module.author-api.service_address}/graphql"
      },
      {
        "name": "REACT_APP_PUBLISHER_URL",
        "value": "${module.publisher.service_address}/publish"
      },
      {
        "name": "REACT_APP_GO_LAUNCH_A_SURVEY_URL",
        "value": "${module.survey-launcher-for-ecs.service_address}/quick-launch"
      },
      {
        "name": "REACT_APP_USE_FULLSTORY",
        "value": "${var.author_use_fullstory}"
      },
      {
        "name": "REACT_APP_USE_SENTRY",
        "value": "${var.author_use_sentry}"
      },
      {
        "name": "REACT_APP_ENABLE_AUTH",
        "value": "${var.author_enable_auth}"
      },
      {
        "name": "REACT_APP_FIREBASE_PROJECT_ID",
        "value": "${var.author_firebase_project_id}"
      },
      {
        "name": "REACT_APP_FIREBASE_API_KEY",
        "value": "${var.author_firebase_api_key}"
      },
      {
        "name": "REACT_APP_FIREBASE_MESSAGING_SENDER_ID",
        "value": "${var.author_firebase_messaging_sender_id}"
      }
  EOF
}

module "author-api" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v1.4.0"
  env                    = "${var.env}"
  aws_access_key         = "${var.aws_access_key}"
  aws_secret_key         = "${var.aws_secret_key}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  aws_alb_arn            = "${module.eq-ecs.aws_alb_arn}"
  service_name           = "author-api"
  listener_rule_priority = 103
  docker_registry        = "${var.author_registry}"
  container_name         = "eq-author-api"
  container_port         = 4000
  container_tag          = "${var.author_api_tag}"
  healthcheck_path       = "/status"
  application_min_tasks  = "${var.author_api_min_tasks}"
  slack_alert_sns_arn    = "${module.survey-runner-alerting.slack_alert_sns_arn}"

  container_environment_variables = <<EOF
      {
        "name": "DB_CONNECTION_URI",
        "value": "postgres://${var.author_database_user}:${var.author_database_password}@${module.author-database.database_address}:${module.author-database.database_port}/${var.author_database_name}"
      }
  EOF
}

module "publisher" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v1.4.0"
  env                    = "${var.env}"
  aws_access_key         = "${var.aws_access_key}"
  aws_secret_key         = "${var.aws_secret_key}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  aws_alb_arn            = "${module.eq-ecs.aws_alb_arn}"
  service_name           = "publisher"
  listener_rule_priority = 104
  docker_registry        = "${var.author_registry}"
  container_name         = "eq-publisher"
  container_port         = 9000
  container_tag          = "${var.publisher_tag}"
  healthcheck_path       = "/status"
  application_min_tasks  = "${var.publisher_min_tasks}"
  slack_alert_sns_arn    = "${module.survey-runner-alerting.slack_alert_sns_arn}"

  container_environment_variables = <<EOF
      {
        "name": "EQ_AUTHOR_API_URL",
        "value": "${module.author-api.service_address}/graphql"
      },
      {
        "name": "EQ_SCHEMA_VALIDATOR_URL",
        "value": "${module.schema-validator.service_address}/validate"
      }
  EOF
}

module "schema-validator" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v1.4.0"
  env                    = "${var.env}"
  aws_access_key         = "${var.aws_access_key}"
  aws_secret_key         = "${var.aws_secret_key}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn            = "${module.eq-ecs.aws_alb_arn}"
  service_name           = "schema-validator"
  listener_rule_priority = 500
  docker_registry        = "${var.schema_validator_registry}"
  container_name         = "eq-schema-validator"
  container_port         = 5000
  container_tag          = "${var.schema_validator_tag}"
  healthcheck_path       = "/status"
  application_min_tasks  = "${var.schema_validator_min_tasks}"
  slack_alert_sns_arn    = "${module.survey-runner-alerting.slack_alert_sns_arn}"
}

module "survey-register" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v1.4.0"
  env                    = "${var.env}"
  aws_access_key         = "${var.aws_access_key}"
  aws_secret_key         = "${var.aws_secret_key}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn            = "${module.eq-ecs.aws_alb_arn}"
  service_name           = "survey-register"
  listener_rule_priority = 600
  docker_registry        = "${var.survey_register_registry}"
  container_name         = "eq-survey-register"
  container_port         = 8080
  container_tag          = "${var.survey_register_tag}"
  application_min_tasks  = "${var.survey_register_min_tasks}"
  slack_alert_sns_arn    = "${module.survey-runner-alerting.slack_alert_sns_arn}"
}

module "survey-runner-database" {
  source                           = "./survey-runner-database"
  env                              = "${var.env}"
  aws_access_key                   = "${var.aws_access_key}"
  aws_secret_key                   = "${var.aws_secret_key}"
  vpc_id                           = "${module.survey-runner-vpc.vpc_id}"
  application_cidrs                = "${concat(var.ecs_application_cidrs, var.application_cidrs)}"
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
  db_subnet_group_name             = "${module.survey-runner-vpc.database_subnet_group_name}"
  database_identifier              = "${var.env}-digitaleqrds"
  rds_security_group_name          = "${var.env}-rds-access"
}

module "author-database" {
  source                           = "./survey-runner-database"
  env                              = "${var.env}"
  aws_access_key                   = "${var.aws_access_key}"
  aws_secret_key                   = "${var.aws_secret_key}"
  vpc_id                           = "${module.survey-runner-vpc.vpc_id}"
  application_cidrs                = "${var.ecs_application_cidrs}"
  private_route_table_ids          = "${module.survey-runner-routing.private_route_table_ids}"
  multi_az                         = "${var.multi_az}"
  backup_retention_period          = "${var.backup_retention_period}"
  database_apply_immediately       = "${var.database_apply_immediately}"
  database_instance_class          = "${var.database_instance_class}"
  database_allocated_storage       = "${var.database_allocated_storage}"
  database_free_memory_alert_level = "${var.database_free_memory_alert_level}"
  database_name                    = "${var.author_database_name}"
  database_user                    = "${var.author_database_user}"
  database_password                = "${var.author_database_password}"
  db_subnet_group_name             = "${module.survey-runner-vpc.database_subnet_group_name}"
  database_identifier              = "${var.env}-authorrds"
  rds_security_group_name          = "${var.env}-author-rds-access"
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
  database_subnet_ids = "${module.survey-runner-vpc.database_subnet_ids}"
  database_cidrs      = "${var.database_cidrs}"
}

module "survey-runner-vpc" {
  source         = "./survey-runner-vpc"
  env            = "${var.env}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
  database_cidrs = "${var.database_cidrs}"
}

module "survey-runner-dynamodb" {
  source                             = "github.com/ONSdigital/eq-terraform-dynamodb"
  env                                = "${var.env}"
  aws_access_key                     = "${var.aws_access_key}"
  aws_secret_key                     = "${var.aws_secret_key}"
  submitted_responses_read_capacity  = 1
  submitted_responses_write_capacity = 1
}

output "survey_runner_beanstalk" {
  value = "${module.survey-runner-on-beanstalk.survey_runner_elb_address}"
}

output "survey_launcher_for_beanstalk" {
  value = "${module.survey-launcher-for-elastic-beanstalk.service_address}"
}

output "survey_runner_ecs" {
  value = "${module.survey-runner-on-ecs.service_address}"
}

output "survey_launcher_for_ecs" {
  value = "${module.survey-launcher-for-ecs.service_address}"
}

output "author_address" {
  value = "${module.author.service_address}"
}
