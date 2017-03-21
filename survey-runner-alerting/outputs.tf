output "cloudwatch_alarm_arn" {
  value = "${aws_sns_topic.slack_alert.arn}"
}
