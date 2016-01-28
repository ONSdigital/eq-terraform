resource "aws_elastic_beanstalk_application" "surveyrunner" {
  name = "${var.env}-surveyrunner"
  description = "Survey runner for environment"
}

resource "aws_elastic_beanstalk_environment" "sr_prime" {
  name = "${var.env}-prime"
  application = "${aws_elastic_beanstalk_application.surveyrunner.name}"
  solution_stack_name = "64bit Amazon Linux 2015.09 v2.0.6 running Python 3.4"
}

resource "aws_route53_record" "survey_runner" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.env}-surveys.${var.dns_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_elastic_beanstalk_environment.sr_prime.cname}"]
}
