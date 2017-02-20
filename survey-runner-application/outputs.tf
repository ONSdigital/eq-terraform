output "survey_runner_elb_address" {
  value = "${aws_route53_record.survey_runner.fqdn}"
}
