resource "aws_iam_role" "iam_for_slack_alert" {
  name = "${var.env}_iam_for_slack_alert"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


data "aws_iam_policy_document" "iam_for_slack_alert" {
  "statement" = {
    "effect" = "Allow",
    "actions" = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ],
    "resources" = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.slack_alert.function_name}:log-stream:*"
    ]
  }

  "statement" = {
    "effect" = "Allow",
    "actions" = [
      "logs:FilterLogEvents"
    ],
    "resources" = [
      "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:${var.env}-*:log-stream:*"
    ]
  }
}

resource "aws_iam_role_policy" "iam_for_slack_alert" {
  name = "${var.env}_iam_for_slack_alert"
  role = "${aws_iam_role.iam_for_slack_alert.id}"
  policy = "${data.aws_iam_policy_document.iam_for_slack_alert.json}"
}
