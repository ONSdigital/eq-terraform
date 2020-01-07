data "archive_file" "slack_alert_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/slack-alert"
  output_path = "${path.module}/lambda/slack-alert.zip"
}

resource "aws_lambda_function" "slack_alert" {
  filename = "${data.archive_file.slack_alert_zip.output_path}"
  function_name = "${var.env}-slack-alert"
  role = "${aws_iam_role.iam_for_slack_alert.arn}"
  handler = "index.handler"
  runtime = "nodejs12.x"
  timeout = "3"
  source_code_hash = "${data.archive_file.slack_alert_zip.output_base64sha256}"
  environment {
    variables = {
      slack_webhook_path = "${var.slack_webhook_path}"
      slack_channel = "${var.slack_channel}"
    }
  }
}

resource "aws_lambda_permission" "slack_alert_from_sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.slack_alert.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.slack_alert.arn}"
}