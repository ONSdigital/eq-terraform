terraform {
  required_version = ">= 0.10.0, < 0.11.0"

  backend "s3" {
    bucket = "eq-terraform-state"
    region = "eu-west-1"
  }
}

module "eq-alerting" {
  source              = "./survey-runner-alerting"
  env                 = "${var.env}"
  aws_account_id      = "${var.aws_account_id}"
  aws_assume_role_arn = "${var.aws_assume_role_arn}"
  slack_webhook_path  = "${var.slack_webhook_path}"
  slack_channel       = "eq-${var.env}-alerts"
}

module "eq-ecs" {
  source                   = "github.com/ONSdigital/eq-terraform-ecs?ref=v7.0"
  env                      = "${var.env}"
  ecs_cluster_name         = "eq-runner"
  aws_account_id           = "${var.aws_account_id}"
  aws_assume_role_arn      = "${var.aws_assume_role_arn}"
  ecs_instance_type        = "${var.ecs_instance_type}"
  certificate_arn          = "${var.certificate_arn}"
  vpc_id                   = "${module.survey-runner-vpc.vpc_id}"
  public_subnet_ids        = "${module.survey-runner-routing.public_subnet_ids}"
  ecs_application_cidrs    = "${var.ecs_application_cidrs}"
  private_route_table_ids  = "${module.survey-runner-routing.private_route_table_ids}"
  ecs_cluster_min_size     = "${var.ecs_cluster_min_size}"
  auto_deploy_updated_tags = "${var.auto_deploy_updated_tags}"
  ons_access_ips           = ["${split(",", var.ons_access_ips)}"]
  gateway_ips              = ["${module.survey-runner-routing.nat_gateway_ips}"]
  create_external_elb      = "${var.create_ecs_external_elb}"
  create_internal_elb      = "${var.create_ecs_internal_elb}"
}

module "survey-runner-on-ecs" {
  source                     = "github.com/ONSdigital/eq-ecs-deploy?ref=v4.1"
  env                        = "${var.env}"
  aws_account_id             = "${var.aws_account_id}"
  aws_assume_role_arn        = "${var.aws_assume_role_arn}"
  vpc_id                     = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name              = "${var.dns_zone_name}"
  ecs_cluster_name           = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn                = "${module.eq-ecs.aws_external_alb_arn}"
  aws_alb_listener_arn       = "${module.eq-ecs.aws_external_alb_listener_arn}"
  service_name               = "surveys"
  listener_rule_priority     = 1000
  docker_registry            = "${var.survey_runner_docker_registry}"
  container_name             = "eq-survey-runner"
  container_port             = 5000
  healthcheck_path           = "/status"
  container_tag              = "${var.survey_runner_tag}"
  application_min_tasks      = "${var.survey_runner_min_tasks}"
  slack_alert_sns_arn        = "${module.eq-alerting.slack_alert_sns_arn}"
  aws_alb_use_host_header    = false

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
        "name": "EQ_QUESTIONNAIRE_STATE_TABLE_NAME",
        "value": "${module.survey-runner-dynamodb.questionnaire_state_table_name}"
      },
      {
        "name": "EQ_QUESTIONNAIRE_STATE_DYNAMO_READ",
        "value": "${var.survey_runner_questionnaire_state_dynamo_read}"
      },
      {
        "name": "EQ_QUESTIONNAIRE_STATE_DYNAMO_WRITE",
        "value": "${var.survey_runner_questionnaire_state_dynamo_write}"
      },
      {
        "name": "EQ_SESSION_TABLE_NAME",
        "value": "${module.survey-runner-dynamodb.eq_session_table_name}"
      },
      {
        "name": "EQ_SESSION_DYNAMO_READ",
        "value": "${var.survey_runner_eq_session_dynamo_read}"
      },
      {
        "name": "EQ_SESSION_DYNAMO_WRITE",
        "value": "${var.survey_runner_eq_session_dynamo_write}"
      },
      {
        "name": "EQ_USED_JTI_CLAIM_TABLE_NAME",
        "value": "${module.survey-runner-dynamodb.used_jti_claim_table_name}"
      },
      {
        "name": "EQ_USED_JTI_CLAIM_DYNAMO_READ",
        "value": "${var.survey_runner_used_jti_claim_dynamo_read}"
      },
      {
        "name": "EQ_USED_JTI_CLAIM_DYNAMO_WRITE",
        "value": "${var.survey_runner_used_jti_claim_dynamo_write}"
      },
      {
        "name": "EQ_NEW_RELIC_ENABLED",
        "value": "${var.survey_runner_new_relic_enabled}"
      },
      {
        "name": "NEW_RELIC_APP_NAME",
        "value": "${var.env} - ${var.survey_runner_new_relic_app_name} - ECS"
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
      },
      {
          "Sid": "",
          "Effect": "Allow",
          "Action": [
              "dynamodb:PutItem",
              "dynamodb:GetItem",
              "dynamodb:DeleteItem"
          ],
          "Resource": "${module.survey-runner-dynamodb.questionnaire_state_table_arn}"
      },
      {
          "Sid": "",
          "Effect": "Allow",
          "Action": [
              "dynamodb:PutItem",
              "dynamodb:GetItem",
              "dynamodb:DeleteItem"
          ],
          "Resource": "${module.survey-runner-dynamodb.eq_session_table_arn}"
      },
      {
          "Sid": "",
          "Effect": "Allow",
          "Action": [
              "dynamodb:PutItem"
          ],
          "Resource": "${module.survey-runner-dynamodb.used_jti_claim_table_arn}"
      }

  ]
}
  EOF
}

module "survey-runner-static-on-ecs" {
  source                     = "github.com/ONSdigital/eq-ecs-deploy?ref=v4.1"
  env                        = "${var.env}"
  aws_account_id             = "${var.aws_account_id}"
  aws_assume_role_arn        = "${var.aws_assume_role_arn}"
  vpc_id                     = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name              = "${var.dns_zone_name}"
  dns_record_name            = "${var.env}-surveys.${var.dns_zone_name}"
  ecs_cluster_name           = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn                = "${module.eq-ecs.aws_external_alb_arn}"
  aws_alb_listener_arn       = "${module.eq-ecs.aws_external_alb_listener_arn}"
  service_name               = "surveys-static"
  listener_rule_priority     = 995
  docker_registry            = "${var.survey_runner_docker_registry}"
  container_name             = "eq-survey-runner-static"
  container_port             = 80
  container_tag              = "${var.survey_runner_tag}"
  application_min_tasks      = "${var.survey_runner_min_tasks}"
  slack_alert_sns_arn        = "${module.eq-alerting.slack_alert_sns_arn}"
  alb_listener_path_patterns = ["/s/*"]
  aws_alb_use_host_header    = false
}

module "survey-launcher-for-ecs" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v4.1"
  env                    = "${var.env}"
  aws_account_id         = "${var.aws_account_id}"
  aws_assume_role_arn    = "${var.aws_assume_role_arn}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn            = "${module.eq-ecs.aws_external_alb_arn}"
  aws_alb_listener_arn   = "${module.eq-ecs.aws_external_alb_listener_arn}"
  service_name           = "surveys-launch"
  listener_rule_priority = 15
  docker_registry        = "${var.survey_launcher_registry}"
  container_name         = "go-launch-a-survey"
  container_port         = 8000
  healthcheck_path       = "/status"
  container_tag          = "${var.survey_launcher_tag}"
  application_min_tasks  = "${var.survey_launcher_min_tasks}"
  slack_alert_sns_arn    = "${module.eq-alerting.slack_alert_sns_arn}"

  container_environment_variables = <<EOF
      {
        "name": "SURVEY_RUNNER_URL",
        "value": "https://${var.env}-surveys.${var.dns_zone_name}"
      },
      {
        "name": "SCHEMA_VALIDATOR_URL",
        "value": "${module.schema-validator.service_address}"
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

module "schema-validator" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v4.1"
  env                    = "${var.env}"
  aws_account_id         = "${var.aws_account_id}"
  aws_assume_role_arn    = "${var.aws_assume_role_arn}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn            = "${module.eq-ecs.aws_external_alb_arn}"
  aws_alb_listener_arn   = "${module.eq-ecs.aws_external_alb_listener_arn}"
  service_name           = "schema-validator"
  listener_rule_priority = 500
  docker_registry        = "${var.schema_validator_registry}"
  container_name         = "eq-schema-validator"
  container_port         = 5000
  container_tag          = "${var.schema_validator_tag}"
  healthcheck_path       = "/status"
  application_min_tasks  = "${var.schema_validator_min_tasks}"
  slack_alert_sns_arn    = "${module.eq-alerting.slack_alert_sns_arn}"
}

module "survey-register" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v4.1"
  env                    = "${var.env}"
  aws_account_id         = "${var.aws_account_id}"
  aws_assume_role_arn    = "${var.aws_assume_role_arn}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn            = "${module.eq-ecs.aws_external_alb_arn}"
  aws_alb_listener_arn   = "${module.eq-ecs.aws_external_alb_listener_arn}"
  service_name           = "survey-register"
  listener_rule_priority = 600
  docker_registry        = "${var.survey_register_registry}"
  container_name         = "eq-survey-register"
  container_port         = 8080
  container_tag          = "${var.survey_register_tag}"
  application_min_tasks  = "${var.survey_register_min_tasks}"
  slack_alert_sns_arn    = "${module.eq-alerting.slack_alert_sns_arn}"
}

module "eq-elasticsearch" {
  source              = "github.com/ONSdigital/eq-terraform-elasticsearch"
  env                 = "${var.env}"
  aws_account_id      = "${var.aws_account_id}"
  aws_assume_role_arn = "${var.aws_assume_role_arn}"
  access_list         = "${concat(module.survey-runner-routing.nat_gateway_ips, split(",", var.ons_access_ips))}"
}

module "eq-suggest-api" {
  source                 = "github.com/ONSdigital/eq-ecs-deploy?ref=v4.1"
  env                    = "${var.env}"
  aws_account_id         = "${var.aws_account_id}"
  aws_assume_role_arn    = "${var.aws_assume_role_arn}"
  vpc_id                 = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name          = "${var.dns_zone_name}"
  ecs_cluster_name       = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn            = "${module.eq-ecs.aws_external_alb_arn}"
  aws_alb_listener_arn   = "${module.eq-ecs.aws_external_alb_listener_arn}"
  service_name           = "lookup-api"
  listener_rule_priority = 700
  docker_registry        = "${var.survey_runner_docker_registry}"
  container_name         = "eq-lookup-api"
  container_port         = 5000
  healthcheck_path       = "/status"
  container_tag          = "${var.suggest_api_tag}"
  slack_alert_sns_arn    = "${module.eq-alerting.slack_alert_sns_arn}"

  container_environment_variables = <<EOF
      {
        "name": "LOOKUP_URL",
        "value": "https://${module.eq-elasticsearch.suggest-endpoint}/"
      }
  EOF
}

module "survey-runner-database" {
  source                           = "./survey-runner-database"
  env                              = "${var.env}"
  aws_account_id                   = "${var.aws_account_id}"
  aws_assume_role_arn              = "${var.aws_assume_role_arn}"
  vpc_id                           = "${module.survey-runner-vpc.vpc_id}"
  application_cidrs                = "${concat(var.ecs_application_cidrs, var.application_cidrs)}"
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

module "survey-runner-queue" {
  source                       = "./survey-runner-queue"
  env                          = "${var.env}"
  aws_account_id               = "${var.aws_account_id}"
  aws_assume_role_arn          = "${var.aws_assume_role_arn}"
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
  aws_account_id      = "${var.aws_account_id}"
  aws_assume_role_arn = "${var.aws_assume_role_arn}"
  public_cidrs        = "${var.public_cidrs}"
  vpc_id              = "${module.survey-runner-vpc.vpc_id}"
  internet_gateway_id = "${module.survey-runner-vpc.internet_gateway_id}"
  database_subnet_ids = "${module.survey-runner-vpc.database_subnet_ids}"
}

module "survey-runner-vpc" {
  source              = "./survey-runner-vpc"
  env                 = "${var.env}"
  aws_account_id      = "${var.aws_account_id}"
  aws_assume_role_arn = "${var.aws_assume_role_arn}"
  vpc_name            = "runner"
  vpc_cidr_block      = "${var.vpc_cidr_block}"
  database_cidrs      = "${var.database_cidrs}"
}

module "survey-runner-dynamodb" {
  source                                 = "github.com/ONSdigital/eq-terraform-dynamodb?ref=v2.2"
  env                                    = "${var.env}"
  aws_account_id                         = "${var.aws_account_id}"
  aws_assume_role_arn                    = "${var.aws_assume_role_arn}"
  slack_alert_sns_arn                    = "${module.eq-alerting.slack_alert_sns_arn}"
}

output "survey_runner_ecs" {
  value = "${module.survey-runner-on-ecs.service_address}"
}

output "survey_launcher_for_ecs" {
  value = "${module.survey-launcher-for-ecs.service_address}"
}
