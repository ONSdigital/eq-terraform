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
variable "dns_zone_id" {
  description = "Amazon Route53 DNS zone identifier"
}

variable "dns_zone_name" {
  description = "Amazon Route53 DNS zone name"
  default     = "dev.eq.ons.digital"
}

variable "aws_key_pair" {
  description = "AWS key pair for queue servers"
}


variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  default = "10.30.20.0/24"
}

variable "queue_cidrs" {
  type        = "list"
  description = "CIDR blocks for queue subnets"
  default = ["10.30.20.0/27"]
}

variable "ecs_application_cidrs" {
  type        = "list"
  description = "CIDR blocks for application subnets"
  default = ["10.30.20.32/28", "10.30.20.48/28", "10.30.20.64/28"]
}

variable "database_cidrs" {
  type        = "list"
  description = "CIDR blocks for database subnets"
  default = ["10.30.20.96/28","10.30.20.112/28"]
}

variable "public_cidrs" {
  type        = "list"
  description = "CIDR blocks for public subnets"
  default = ["10.30.20.144/28", "10.30.20.160/28", "10.30.20.176/28"]
}

variable "application_cidrs" {
  type        = "list"
  description = "CIDR blocks for application subnets"
  default = ["10.30.20.192/28", "10.30.20.208/28", "10.30.20.224/28"]
}

variable "sdx_cidrs" {
  type        = "list"
  description = "CIDR blocks of the sdx system"
  default = ["10.99.0.1/32"]
}

variable "rsyslogd_server_ip" {
  description = "The IP of the centralised syslog service."
  default = "10.99.0.2"
}

variable "logserver_cidr" {
  description = "CIDR block of the centralised logging service"
  default = "10.99.0.3/32"
}

variable "audit_cidr" {
  description = "CIDR block of the centralised auditing service."
  default = "10.99.0.4/32"
}


variable "slack_webhook_path" {
  description = "Slack Webhook path for the alert. Obtained via, https://api.slack.com/incoming-webhooks"
}


variable "application_secret_key" {
  description = "The Flask secret key for secure cookie storage"
  default = "you'll never guess it"
}

variable "ons_access_ips" {
  description = "List of IP's or IP ranges to allow access to eQ"
}

variable "google_analytics_code" {
  description = "The google analytics UA Code"
  default = ""
}

variable "certificate_arn" {
  description = "ARN of the IAM loaded TLS certificate for public ELB"
}

variable "rabbitmq_admin_user" {
  description = "The admin user to create for rabbitmq"
  default = "admin"
}

variable "rabbitmq_admin_password" {
  description = "The admin user password for rabbitmq"
  default = "test1"
}

variable "rabbitmq_write_user" {
  description = "The 'write-only' user to create for rabbitmq"
  default = "writeonly"
}

variable "rabbitmq_write_password" {
  description = "The 'write-only' user password for rabbitmq"
  default = "test2"
}

variable "rabbitmq_read_user" {
  description = "The 'read-only' user to create for rabbitmq"
  default = "readonly"
}

variable "rabbitmq_read_password" {
  description = "The 'read-only' user password for rabbitmq"
  default = "test3"
}

variable "multi_az" {
  description = "Distribute database across multiple availability zones"
  default     = false
}

variable "backup_retention_period" {
  description = "How many days database backup to keep"
  default     = 0
}

variable "eb_deployment_policy" {
  description = "Elastic Beanstalk DeploymentPolicy"
  default     = "AllAtOnce"
}

variable "eb_rolling_update_enabled" {
  description = "Elastic Beanstalk RollingUpdateEnabled"
  default     = "false"
}

variable "survey_launcher_s3_secrets_bucket" {
  description = "The S3 bucket that contains the secrets"
  default = ""
}

variable "survey_launcher_jwt_encryption_key_path" {
  description = "Path to the JWT Encryption Key (PEM format)"
  default = "jwt-test-keys/sdc-user-authentication-encryption-sr-public-key.pem"
}

variable "survey_launcher_jwt_signing_key_path" {
  description = "Path to the JWT Signing Key (PEM format)"
  default = "jwt-test-keys/sdc-user-authentication-signing-rrm-private-key.pem"
}