terraform {
  required_version = ">= 0.10.0, < 0.11.0"

  backend "s3" {
    bucket = "eq-terraform-state"
    region = "eu-west-1"
  }
}

provider "aws" {
  allowed_account_ids = ["${var.aws_account_id}"]

  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }

  region = "eu-west-1"
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
  source                  = "github.com/ONSdigital/eq-terraform-ecs?ref=v7.2"
  env                     = "${var.env}"
  ecs_cluster_name        = "eq-runner"
  aws_account_id          = "${var.aws_account_id}"
  aws_assume_role_arn     = "${var.aws_assume_role_arn}"
  ecs_instance_type       = "${var.ecs_instance_type}"
  certificate_arn         = "${var.certificate_arn}"
  vpc_id                  = "${module.survey-runner-vpc.vpc_id}"
  public_subnet_ids       = "${module.survey-runner-routing.public_subnet_ids}"
  ecs_application_cidrs   = "${var.ecs_application_cidrs}"
  private_route_table_ids = "${module.survey-runner-routing.private_route_table_ids}"
  ecs_cluster_min_size    = "${var.ecs_cluster_min_size}"
  ons_access_ips          = ["${split(",", var.ons_access_ips)}"]
  gateway_ips             = ["${module.survey-runner-routing.nat_gateway_ips}"]
  create_external_elb     = "${var.create_ecs_external_elb}"
  create_internal_elb     = "${var.create_ecs_internal_elb}"
  ecs_cluster_min_size    = 0
  ecs_cluster_max_size    = 0
}

module "survey-runner-on-ecs" {
  source                  = "github.com/ONSdigital/eq-ecs-deploy?ref=v4.1"
  env                     = "${var.env}"
  aws_account_id          = "${var.aws_account_id}"
  aws_assume_role_arn     = "${var.aws_assume_role_arn}"
  vpc_id                  = "${module.survey-runner-vpc.vpc_id}"
  dns_zone_name           = "${var.dns_zone_name}"
  ecs_cluster_name        = "${module.eq-ecs.ecs_cluster_name}"
  aws_alb_arn             = "${module.eq-ecs.aws_external_alb_arn}"
  aws_alb_listener_arn    = "${module.eq-ecs.aws_external_alb_listener_arn}"
  service_name            = "surveys"
  listener_rule_priority  = 1000
  docker_registry         = "${var.survey_runner_docker_registry}"
  container_name          = "eq-survey-runner"
  container_port          = 5000
  healthcheck_path        = "/status"
  container_tag           = "${var.survey_runner_tag}"
  application_min_tasks   = "${var.survey_runner_min_tasks}"
  slack_alert_sns_arn     = "${module.eq-alerting.slack_alert_sns_arn}"
  aws_alb_use_host_header = false
  ecs_subnet_ids          = "${module.eq-ecs.ecs_subnet_ids}"
  ecs_alb_security_group  = ["${module.eq-ecs.ecs_alb_security_group}"]
  launch_type             = "FARGATE"
  cpu_units               = "4096"
  memory_units            = "8192"

  container_environment_variables = <<EOF
      {
        "name": "EQ_STORAGE_BACKEND",
        "value": "dynamodb"
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
        "name": "EQ_SUBMISSION_BACKEND",
        "value": "log"
      },
      {
        "name": "GUNICORN_WORKERS",
        "value": "9"
      },
      {
        "name": "EQ_REDIS_HOST",
        "value": "${aws_elasticache_cluster.memory-store.cache_nodes.0.address}"
      },
      {
        "name": "EQ_REDIS_PORT",
        "value": "${aws_elasticache_cluster.memory-store.cache_nodes.0.port}"
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
  ecs_subnet_ids         = "${module.eq-ecs.ecs_subnet_ids}"
  ecs_alb_security_group = ["${module.eq-ecs.ecs_alb_security_group}"]
  launch_type            = "FARGATE"

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
  source              = "github.com/ONSdigital/eq-terraform-dynamodb?ref=v2.2"
  env                 = "${var.env}"
  aws_account_id      = "${var.aws_account_id}"
  aws_assume_role_arn = "${var.aws_assume_role_arn}"
  slack_alert_sns_arn = "${module.eq-alerting.slack_alert_sns_arn}"
}

resource "aws_elasticache_cluster" "memory-store" {
  cluster_id                   = "${var.env}-redis"
  engine                       = "redis"
  node_type                    = "cache.t2.small"
  num_cache_nodes              = 1
  parameter_group_name         = "default.redis5.0"
  engine_version               = "5.0.3"
  subnet_group_name            = "${aws_elasticache_subnet_group.memory-store.name}"
  security_group_ids           = ["${aws_security_group.memory-store-access.id}"]
  availability_zone            = "eu-west-1a"
  port                         = 6379
}

resource "aws_elasticache_subnet_group" "memory-store" {
  name       = "${var.env}-memory-store-subnet-group"
  subnet_ids = ["${module.survey-runner-vpc.database_subnet_ids}"]
}

resource "aws_security_group" "memory-store-access" {
  name        = "${var.env}-memory-store-access"
  description = "Redis access from the application subnet"
  vpc_id      = "${module.survey-runner-vpc.vpc_id}"

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = "${var.ecs_application_cidrs}"
  }

  tags {
    Name = "${var.env}-memory-store-security-group"
  }
}

output "survey_runner_ecs" {
  value = "${module.survey-runner-on-ecs.service_address}"
}

output "survey_launcher_for_ecs" {
  value = "${module.survey-launcher-for-ecs.service_address}"
}
