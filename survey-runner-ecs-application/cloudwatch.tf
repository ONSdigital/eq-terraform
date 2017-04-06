resource "aws_cloudwatch_log_group" "eq-survey-runner" {
  name = "${var.env}-eq-survey-runner"

  tags {
    Environment = "${var.env}"
  }
}