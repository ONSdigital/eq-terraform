resource "aws_sns_topic" "slack_alert" {
  name = "${var.env}-slack-alert"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = "${aws_sns_topic.slack_alert.arn}"
  protocol = "lambda"
  endpoint = "${aws_lambda_function.slack_alert.arn}"
}