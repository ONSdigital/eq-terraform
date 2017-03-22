resource "aws_cloudwatch_metric_alarm" "rabbitmq1_cluster_status" {
  alarm_name          = "${var.env}-rabbitmq1-cluster-alert"
  evaluation_periods  = "1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "${var.env}-rabbitmq1"
  namespace           = "RabbitMQClusterStatus"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "${var.env} rabbit mq 1 reporting cluster paritions"
  alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]
  insufficient_data_actions = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]
}

resource "aws_cloudwatch_metric_alarm" "rabbitmq2_cluster_status" {
  alarm_name          = "${var.env}-rabbitmq2-cluster-alert"
  evaluation_periods  = "1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "${var.env}-rabbitmq2"
  namespace           = "RabbitMQClusterStatus"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "${var.env} rabbit mq 2 reporting cluster paritions"
  alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]
  insufficient_data_actions = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]
}

resource "aws_cloudwatch_metric_alarm" "rabbitmq_cpu" {
  count               = 2
  alarm_name          = "${var.env}-rabbitmq${count.index + 1}-cpu-alert"
  evaluation_periods  = "1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert generated if over 80% CPU usage"
  alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]

  dimensions {
    "InstanceId" = "${element(aws_instance.rabbitmq.*.id,count.index)}"
  }
}

resource "aws_cloudwatch_metric_alarm" "rabbitmq_status" {
  count               = 2
  alarm_name          = "${var.env}-rabbitmq-${count.index + 1}-status-alert"
  evaluation_periods  = "1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Alert generated if status changes to failure"
  alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]
  insufficient_data_actions = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.env}-slack-alert"]

  dimensions {
    "InstanceId" = "${element(aws_instance.rabbitmq.*.id,count.index)}"
  }
}
