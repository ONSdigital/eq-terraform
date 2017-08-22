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

// ECS
variable "ecs_instance_type" {
  description = "ECS Instance Type"
  default     = "t2.micro"
}

  variable "jenkins_snapshot_retention_days" {
  description = "How many days to keep backup of queues"
  default     = 1
}

variable "backup_retention_period" {
  description = "How many days database backup to keep"
  default     = 0
}

variable "aws_default_region" {
  description = "The default region for AWS Services"
  default     = "eu-west-1"
}

variable "jenkins_snapshot_cron"{
    description = "Timescale for when the job is to be run"
    default = "27 * * * ? *"
}
