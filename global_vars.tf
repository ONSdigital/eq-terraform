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
