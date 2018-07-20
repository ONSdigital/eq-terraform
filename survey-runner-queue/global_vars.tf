variable "env" {
  description = "The environment you wish to use"
}

variable "aws_account_id" {
  description = "Amazon Web Service Account ID"
}

variable "aws_assume_role_arn" {
  description = "IAM Role to assume on AWS"
}

variable "availability_zones" {
  type        = "list"
  description = "The availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "vpc_id" {
  description = "The survey runner VPC ID"
}

variable "queue_cidrs" {
  type        = "list"
  description = "CIDR blocks for queue subnets"
}

variable "application_cidrs" {
  type        = "list"
  description = "CIDR blocks for application subnets"
}

variable "sdx_cidrs" {
  type        = "list"
  description = "CIDR blocks of the sdx system"
}

variable "internet_gateway_id" {
  description = "An existing VPC Internet Gateway ID"
}

variable "virtual_private_gateway_id" {
  type = "list"
  description = "An existing Virtual Private Gateway ID"
  default = []
}

# DNS
variable "dns_zone_name" {
  description = "Amazon Route53 DNS zone name"
  default     = "eq.ons.digital."
}

# RabbitMQ
variable "rabbitmq_instance_type" {
  description = "Rabbit MQ Instance type"
  default     = "t2.medium"
}

variable "ebs_snapshot_cron"{
    description = "Timescale for when the job is to be run"
    default = "0 0 * * ? *"
}

variable "ebs_snapshot_retention_days" {
    description = "How many days to keep backups of volumes"
    default   = 10
}

variable "rabbitmq_ips" {
  type        = "list"
  description = "Static IPs of rabbitmq servers (prime,secondary)"
  default = ["10.30.20.15","10.30.20.16"]
}

variable "aws_key_pair" {
  description = "AWS key pair for queue servers"
}

variable "rabbitmq_admin_user" {
  description = "The admin user to create for rabbitmq"
}

variable "rabbitmq_admin_password" {
  description = "The admin user password for rabbitmq"
}

variable "rabbitmq_read_user" {
  description = "The 'read-only' user to create for rabbitmq"
}

variable "rabbitmq_read_password" {
  description = "The 'read-only' user password for rabbitmq"
}

variable "rabbitmq_write_user" {
  description = "The 'write-only' user to create for rabbitmq"
}

variable "rabbitmq_write_password" {
  description = "The 'write-only' user password for rabbitmq"
}

variable "aws_default_region" {
  description = "The default region for AWS Services"
  default     = "eu-west-1"
}

variable "rsyslogd_server_ip" {
  description = "The IP of the centralised syslog service."
}

variable "logserver_cidr" {
  description = "CIDR block of the centralised logging service"
}

variable "audit_cidr" {
  description = "CIDR block of the centralised auditing service."
}

variable "delete_volume_on_termination" {
  description = "Delete EC2 volumes on termination of EC2 instance."
  default     = false
}
