variable "env" {
     description = "The environment you wish to use."
}

variable "aws_secret_key" {
    description = "Amazon Web Service Secret Key."
}

variable "aws_access_key"  {
    description = "Amazon Web Service Access Key;"
}

variable "aws_key_pair" {
    description = "Amazon Web Service Key Pair;"
    default="pre-prod"
}

variable "dns_zone_id" {
  description = "Amazon Route53 DNS zone identifier"
  default = "Z2XIERRF1SJEYP"
}

variable "dns_zone_name" {
  description = "Amazon Route53 DNS zone name"
  default     = "eq.ons.digital."
}

variable "message_queue_name" {
  description = "RabbitMQ submission queue name"
  default     = "submit_q"
}

variable "survey_runner_env" {
  description = "The name of the survey runner environment, which is set as a environment variable."
  default     = "development"
}

variable "aws_default_region" {
  description = "The default region for AWS Services"
  default     = "eu-west-1"
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

variable "eq_sr_log_level" {
  description = "The Survey Runner logging level (One of ['CRITICAL', 'ERROR', 'WARNING', 'INFO', 'DEBUG'])"
  default     = "WARNING"
}

variable "eb_instance_type" {
  description = "Elastic Beanstalk Instance Type"
  default     = "t2.medium"
}

variable "eb_min_size" {
  description = "Elastic Beanstalk Minimum number of instances"
  default     = "2"
}

variable "eb_max_size" {
  description = "Elastic Beanstalk Maximum number of instances"
  default     = "2"
}

variable "rabbitmq_instance_type" {
  description = "Rabbit MQ Instance type"
  default = "t2.small"
}

variable "cloudwatch_alarm_arn" {
  description = "arn for cloudwatch"
  default = "arn:aws:sns:eu-west-1:229460966734:eq-alert"
}

variable "cloudwatch_logging" {
  description = "Enable Cloudwatch logging"
  default = "True"
}

variable "vpc_ip_block" {
  description = "VPC internal IP cidr block for ec2 machines"
}

variable "rabbitmq_ip_prime" {
  description = "Static IP of prime rabbitmq server"
}

variable "rabbitmq_ip_failover" {
  description = "Static IP of secondary failover rabbitmq server"
}
variable "rabbitmq_ips" {
  description = "Set of IPS for our rabbitmq machines static for VPN"
  default = {}
}
variable "aws_elastic_beanstalk_solution_stack_name" {
  description = "Elastic Beanstalk Amazon Linux version"
  default = "64bit Amazon Linux 2016.03 v2.1.0 running Python 3.4"
}

variable "ons_access_ips" {
  description = "List of IP's or IP ranges to allow access to our service."
}

variable "certificate_arn" {
  description = "ARN of the IAM loaded TLS certificate for public ELB"
}

variable "application_secret_key" {
  description = "The Flask secret key for secure cookie storage"
}

variable "google_analytics_code" {
  description = "The google analytics UA Code"
}

variable "logserver_cidr" {
  description="CIDR block of the centralised logging service"
}

variable "audit_cidr" {
  description="CIDR block of the centralised auditing service."
}

variable "sdx_cidr" {
  description="CIDR block of the sdx system."
}
