resource "aws_lambda_function" "slack_alert" {
  filename = "lambda/slack-alert.zip"
  function_name = "${var.env}-slack-alert"
  role = "${aws_iam_role.iam_for_slack_alert.arn}"
  handler = "slack-alert.handler"
  runtime = "nodejs4.3"
  timeout = "3"
  source_code_hash = "${base64sha256(file("lambda/slack-alert.zip"))}"
  environment {
    variables = {
      slack_webhook_path = "${var.slack_webhook_path}"
      environment_name = "${var.env}"
    }
  }

  tags {
    Environment = "${var.env}"
  }
}

resource "aws_lambda_permission" "slack_alert_from_sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.slack_alert.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.slack_alert.arn}"

  tags {
    Environment = "${var.env}"
  }
}