output "key_pair_name" {
	value = "${var.aws_key_pair}"
}
output "rabbitmq_elb_address" {
	value = "${aws_elb.rabbitmq.dns_name}"
}
output "survey_runner_elb_address" {
  value = "${aws_elastic_beanstalk_environment.sr_prime.cname}"
}
