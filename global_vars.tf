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

variable "submissions_bucket_name" {
  description = "S3 bucket name for encrypted submissions."
  default     = "pillar_box"
}

variable "message_queue_name" {
  description = "RabbitMQ submission queue name"
  default     = "submit_q"
}

variable "sub_aws_access_key" {
  description = "AWS submission access key for submissions bucket."
}

variable "sub_aws_secret_key" {
  description = "AWS submission secret key for accessing submissions bucket."
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
  default     = "t2.small"
}

variable "submitter_instance_type" {
  description = "Submitter Instance Type"
  default     = "t2.small"
}

variable "rabbitmq_instance_type" {
  description = "Rabbit MQ Instance type"
  default = "t2.small"
}

variable "cloudwatch_alarm_arn" {
  description = "arn for cloudwatch"
  default = "arn:aws:sns:eu-west-1:229460966734:eq-alert"
}

variable "vpc_ip_block" {
  description = "VPC internal IP cidr block for ec2 machines"
  default = "10.30.20.0/24"
}

variable "rabbitmq_ip_prime" {
  description = "Static IP of prime rabbitmq server"
  default =  "10.30.20.15"
}

variable "rabbitmq_ip_failover" {
  description = "Static IP of secondary failover rabbitmq server"
  default = "10.30.20.16"
}
