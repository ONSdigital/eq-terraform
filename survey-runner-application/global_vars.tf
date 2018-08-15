variable "env" {
  description = "The environment you wish to use"
}

variable "aws_account_id" {
  description = "Amazon Web Service Account ID"
}

variable "aws_assume_role_arn" {
  description = "IAM Role to assume on AWS"
}

variable "vpc_id" {
  description = "The survey runner VPC ID"
}

variable "vpc_peer_cidr_block" {
  description = "The CIDR block of the peered VPC, optional"
  default     = ""
}

variable "public_subnet_ids" {
  type        = "list"
  description = "The IDs of the public subnets for the external ELBs"
}

variable "private_route_table_ids" {
  type        = "list"
  description = "Route tables with route to NAT gateway"
}

variable "application_cidrs" {
  type        = "list"
  description = "CIDR blocks for application subnets"
}

variable "use_internal_elb" {
  description = "Set to true to use an internal load balancer"
  default     = true
}

variable "availability_zones" {
  type        = "list"
  description = "The availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "ons_access_ips" {
  description = "List of IP's or IP ranges to allow access to eQ"
}

# DNS
variable "dns_zone_name" {
  description = "Amazon Route53 DNS zone name"
  default     = "eq.ons.digital."
}

# EB Configuration
variable "aws_elastic_beanstalk_solution_stack_name" {
  description = "Elastic Beanstalk Amazon Linux version"
  default     = "64bit Amazon Linux 2017.03 v2.4.0 running Python 3.4"
}

variable "eb_instance_type" {
  description = "Elastic Beanstalk Instance Type"
  default     = "t2.medium"
}

variable "eb_min_size" {
  description = "Elastic Beanstalk Minimum number of instances"
  default     = "3"
}

variable "eb_max_size" {
  description = "Elastic Beanstalk Maximum number of instances"
  default     = "24"
}

variable "wsgi_number_of_processes" {
  description = "The number of daemon processes that should be started for the process group when running WSGI applications"
  default     = 15
}

variable "wsgi_number_of_threads" {
  description = "The number of threads to be created to handle requests in each daemon process within the process group when running WSGI applications"
  default     = 10
}

variable "elastic_beanstalk_aws_key_pair" {
  description = "Amazon Web Service Key Pair for use by elastic beanstalk - in production this value should be empty"
  default     = ""
}

variable "certificate_arn" {
  description = "ARN of the IAM loaded TLS certificate for public ELB"
}

# EB Application Configuration
variable "aws_default_region" {
  description = "The default region for AWS Services"
  default     = "eu-west-1"
}

variable "eq_log_level" {
  description = "The Survey Runner logging level (One of ['CRITICAL', 'ERROR', 'WARNING', 'INFO', 'DEBUG'])"
  default     = "INFO"
}

variable "google_analytics_code" {
  description = "The google analytics UA Code"
}

variable "deployment_policy" {
  description = "Elastic Beanstalk DeploymentPolicy"
  default     = "Immutable"
}

variable "rolling_update_enabled" {
  description = "Elastic Beanstalk RollingUpdateEnabled"
  default     = "true"
}

variable "secrets_file_name" {
  description = "The filename of the file containing the application secrets"
  default     = "secrets.yml"
}

variable "respondent_account_url" {
  description = "The url for the respondent log in"
  default     = "https://survey.ons.gov.uk/"
}

# Database
variable "database_address" {
  description = "The address of the postgres database"
}

variable "database_port" {
  description = "The port of the postgres database"
}

variable "database_name" {
  description = "The name of the database"
}

# RabbitMQ
variable "rabbitmq_ip_prime" {
  description = "Static IP of prime rabbitmq server"
}

variable "rabbitmq_ip_failover" {
  description = "Static IP of secondary failover rabbitmq server"
}

variable "message_queue_name" {
  description = "RabbitMQ submission queue name"
  default     = "submit_q"
}

variable "submitted_responses_table_name" {
  description = "Table name of table used for storing Submitted Responses"
}

variable "questionnaire_state_table_name" {
  description = "Table name of table used for storing questionnaire state"
}

variable "questionnaire_state_dynamo_read" {
  description = "Whether survey runner should read from DynmoDB for Questionnaire State objects"
  default     = "False"
}

variable "questionnaire_state_dynamo_write" {
  description = "Whether survey runner should write to DynmoDB for Questionnaire State objects"
  default     = "False"
}

variable "eq_session_table_name" {
  description = "Table name of table used for storing user sessions"
}

variable "eq_session_dynamo_read" {
  description = "Whether survey runner should read from DynmoDB for EQ Session objects"
  default     = "False"
}

variable "eq_session_dynamo_write" {
  description = "Whether survey runner should write to DynmoDB for EQ Session objects"
  default     = "False"
}

variable "used_jti_claim_table_name" {
  description = "Table name of table used for storing used JTI claims"
}

variable "used_jti_claim_dynamo_read" {
  description = "Whether survey runner should read from DynmoDB for Used JTI Claim objects"
  default     = "False"
}

variable "used_jti_claim_dynamo_write" {
  description = "Whether survey runner should write to DynmoDB for Used JTI Claim objects"
  default     = "False"
}

# Survey Runner New Relic
variable "new_relic_enabled" {
  description = "Enable NewRelic monitoring"
  default     = "False"
}

variable "new_relic_app_name" {
  description = "NewRelic App Name"
  default     = "Survey Runner"
}

variable "new_relic_licence_key" {
  description = "NewRelic Licence Key"
  default     = ""
}
