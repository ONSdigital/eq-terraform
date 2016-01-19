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
