variable "env" {
  description = "The environment you wish to use"
}

variable "aws_secret_key" {
  description = "Amazon Web Service Secret Key"
}

variable "aws_access_key" {
  description = "Amazon Web Service Access Key"
}

# DNS
variable "dns_zone_name" {
  description = "Amazon Route53 DNS zone name"
  default     = "dev.eq.ons.digital"
}

variable "aws_key_pair" {
  description = "AWS key pair for queue servers"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  default     = "10.30.20.0/24"
}

variable "queue_cidrs" {
  type        = "list"
  description = "CIDR blocks for queue subnets"
  default     = ["10.30.20.0/27"]
}

variable "ecs_application_cidrs" {
  type        = "list"
  description = "CIDR blocks for application subnets"
  default     = ["10.30.20.32/28", "10.30.20.48/28", "10.30.20.64/28"]
}

variable "database_cidrs" {
  type        = "list"
  description = "CIDR blocks for database subnets"
  default     = ["10.30.20.96/28", "10.30.20.112/28", "10.30.20.128/28"]
}

variable "public_cidrs" {
  type        = "list"
  description = "CIDR blocks for public subnets"
  default     = ["10.30.20.144/28", "10.30.20.160/28", "10.30.20.176/28"]
}

variable "application_cidrs" {
  type        = "list"
  description = "CIDR blocks for application subnets"
  default     = ["10.30.20.192/28", "10.30.20.208/28", "10.30.20.224/28"]
}

variable "sdx_cidrs" {
  type        = "list"
  description = "CIDR blocks of the sdx system"
  default     = ["10.99.0.1/32"]
}

variable "rsyslogd_server_ip" {
  description = "The IP of the centralised syslog service."
  default     = "10.99.0.2"
}

variable "logserver_cidr" {
  description = "CIDR block of the centralised logging service"
  default     = "10.99.0.3/32"
}

variable "audit_cidr" {
  description = "CIDR block of the centralised auditing service."
  default     = "10.99.0.4/32"
}

// Alerting
variable "slack_webhook_path" {
  description = "Slack Webhook path for the alert. Obtained via, https://api.slack.com/incoming-webhooks"
}

// ECS
variable "ecs_instance_type" {
  description = "ECS Instance Type"
  default     = "t2.medium"
}

variable "ecs_cluster_min_size" {
  description = "ECS Cluster Minimum number of instances"
  default     = "2"
}

variable "auto_deploy_updated_tags" {
  description = "Should updated tags of images be automatically deployed"
  default     = "true"
}

// Survey Runner on Elastic Beanstalk
variable "eb_instance_type" {
  description = "Elastic Beanstalk Instance Type"
  default     = "t2.small"
}

variable "eb_min_size" {
  description = "Elastic Beanstalk Minimum number of instances"
  default     = "1"
}

variable "use_internal_elb" {
  description = "Set to true to use an internal load balancer"
  default     = false
}

variable "ons_access_ips" {
  description = "List of IP's or IP ranges to allow access to eQ"
}

variable "google_analytics_code" {
  description = "The google analytics UA Code"
  default     = ""
}

variable "certificate_arn" {
  description = "ARN of the IAM loaded TLS certificate for public ELB"
}

variable "eb_deployment_policy" {
  description = "Elastic Beanstalk DeploymentPolicy"
  default     = "AllAtOnce"
}

variable "eb_rolling_update_enabled" {
  description = "Elastic Beanstalk RollingUpdateEnabled"
  default     = "false"
}

# Survey Runner on ECS
variable "survey_runner_s3_secrets_bucket" {
  description = "The S3 bucket that contains the secrets"
  default     = ""
}

variable "survey_runner_secrets_file_name" {
  description = "The filename of the file containing the application secrets"
  default     = "docker-secrets.yml"
}

variable "survey_runner_docker_registry" {
  description = "The docker repository for the Survey Runner image"
  default     = "onsdigital"
}

variable "survey_runner_tag" {
  description = "The tag for the Survey Runner image to run"
  default     = "latest"
}

variable "survey_runner_min_tasks" {
  description = "The minimum number of Survey Runner tasks to run"
  default     = "1"
}

variable "respondent_account_url" {
  description = "The url for the respondent log in"
  default     = "https://survey.ons.gov.uk/"
}

// RabbitMQ
variable "rabbitmq_instance_type" {
  description = "Rabbit MQ Instance type"
  default     = "t2.nano"
}

variable "rabbitmq_admin_user" {
  description = "The admin user to create for rabbitmq"
  default     = "admin"
}

variable "rabbitmq_admin_password" {
  description = "The admin user password for rabbitmq"
  default     = "test1"
}

variable "rabbitmq_write_user" {
  description = "The 'write-only' user to create for rabbitmq"
  default     = "digitaleq"
}

variable "rabbitmq_write_password" {
  description = "The 'write-only' user password for rabbitmq"
  default     = "digitaleq"
}

variable "rabbitmq_read_user" {
  description = "The 'read-only' user to create for rabbitmq"
  default     = "readonly"
}

variable "rabbitmq_read_password" {
  description = "The 'read-only' user password for rabbitmq"
  default     = "test3"
}

variable "rabbitmq_delete_volume_on_termination" {
  description = "Delete RabbitMQ EC2 volumes on termination of EC2 instance."
  default     = true
}

variable "rabbitmq_ebs_snapshot_retention_days" {
  description = "How many days to keep backup of queues"
  default     = 1
}

// RDS
variable "database_instance_class" {
  description = "The size of the DB instance"
  default     = "db.t2.small"
}

variable "database_allocated_storage" {
  description = "The allocated storage for the database (in GB)"
  default     = 10
}

variable "database_free_memory_alert_level" {
  description = "The level at which to alert about lack of freeable memory (MB)"
  default     = 128
}

variable "database_apply_immediately" {
  description = "Apply changes to the database immediately and not during next maintenance window"
  default     = true
}

variable "database_name" {
  description = "The name of the database"
  default     = "digitaleqrds"
}

variable "database_user" {
  description = "The master username for the database"
  default     = "digitaleq"
}

variable "database_password" {
  description = "The password for the master username of the database"
  default     = "digitaleq"
}

variable "multi_az" {
  description = "Distribute database across multiple availability zones"
  default     = false
}

variable "backup_retention_period" {
  description = "How many days database backup to keep"
  default     = 0
}

// ECS Launcher
variable "survey_launcher_registry" {
  description = "The docker repository for the Survey Launcher image to run"
  default     = "onsdigital"
}

variable "survey_launcher_tag" {
  description = "The tag for the Survey Launcher image to run"
  default     = "latest"
}

variable "survey_launcher_s3_secrets_bucket" {
  description = "The S3 bucket that contains the secrets"
  default     = ""
}

variable "survey_launcher_jwt_encryption_key_path" {
  description = "Path to the JWT Encryption Key (PEM format)"
  default     = "jwt-test-keys/sdc-user-authentication-encryption-sr-public-key.pem"
}

variable "survey_launcher_jwt_signing_key_path" {
  description = "Path to the JWT Signing Key (PEM format)"
  default     = "jwt-test-keys/sdc-user-authentication-signing-rrm-private-key.pem"
}


// Author
variable "author_tag" {
  description = "The tag for the Author image to run"
  default     = "latest"
}

variable "author_api_tag" {
  description = "The tag for the Author API image to run"
  default     = "latest"
}

variable "publisher_tag" {
  description = "The tag for the Publisher image to run"
  default     = "latest"
}

// Schema Validator
variable "schema_validator_registry" {
  description = "The docker repository for the Schema Validator image to run"
  default     = "onsdigital"
}

variable "schema_validator_tag" {
  description = "The tag for the Schema Validator image to run"
  default     = "latest"
}