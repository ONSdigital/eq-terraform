resource "aws_elastic_beanstalk_application" "surveyrunner" {
  name = "${var.env}-surveyrunner"
  description = "Survey runner for environment"
}

resource "aws_elastic_beanstalk_environment" "sr_prime" {
  name = "${var.env}-prime"
  application = "${aws_elastic_beanstalk_application.surveyrunner.name}"
  solution_stack_name = "64bit Amazon Linux 2015.09 v2.0.6 running Python 3.4"

  setting {
    namespace = "aws:ec2:vpc"
    name      =  "VPCId"
    value     = "${aws_vpc.default.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.default.id}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SR_ENVIRONMENT"
    value     = "${var.survey_runner_env}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_RABBITMQ_URL"
    value     = "amqp://admin:admin@${aws_elb.rabbitmq.dns_name}:5672/%2F"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_RABBITMQ_QUEUE_NAME"
    value     = "${var.message_queue_name}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_RABBITMQ_TEST_QUEUE_NAME"
    value     = "${var.message_queue_name}"
  }
  # Extra settings still to implement
  # EQ_RRM_PUBLIC_KEY = os.getenv('EQ_RRM_PUBLIC_KEY', './jwt-test-keys/rrm-public.pem')
  # EQ_SR_PRIVATE_KEY = os.getenv('EQ_SR_PRIVATE_KEY', './jwt-test-keys/sr-private.pem')

  provisioner "local-exec" {
       command = "./deploy_surveyrunner.sh ${var.env}-surveyrunner ${var.env}-prime"
   }
}


resource "aws_route53_record" "survey_runner" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.env}-surveys.${var.dns_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_elastic_beanstalk_environment.sr_prime.cname}"]
}
