output "cloudwatch_alarm_arn" {
  value = "${aws_sns_topic.slack_alert.arn}"
}

output "slack_alert_sns_arn" {
  value = "${aws_sns_topic.slack_alert.arn}"
}