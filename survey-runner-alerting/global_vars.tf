variable "env" {
  description = "The environment you wish to use"
}

variable "aws_account_id" {
  description = "Amazon Web Service Account ID"
}

variable "aws_assume_role_arn" {
  description = "IAM Role to assume on AWS"
}

variable "slack_webhook_path" {
  description = "Slack Webhook path for the alert. Obtained via, https://api.slack.com/incoming-webhooks"
}

variable "slack_channel" {
  description = "The slack channel to send alerts to"
}
