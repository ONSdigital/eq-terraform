output "key_pair_name" {
	value = "${var.aws_key_pair}"
}
output "survey_runner_elb_address" {
  value = "${aws_route53_record.survey_runner.fqdn}"
}
