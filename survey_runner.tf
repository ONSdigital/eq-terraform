resource "aws_elastic_beanstalk_application" "surveyrunner" {
  name = "${var.env}-surveyrunner"
  description = "Survey runner for environment"
}

resource "aws_elastic_beanstalk_environment" "sr_prime" {
  name = "${var.env}-prime"
  application = "${aws_elastic_beanstalk_application.surveyrunner.name}"
  solution_stack_name = "${var.aws_elastic_beanstalk_solution_stack_name}"

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
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = "${aws_security_group.ons_ips.id}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = "${aws_security_group.ons_ips.id}"
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

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.eb_instance_type}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_LOG_LEVEL"
    value     = "${var.eq_sr_log_level}"
  }

   setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_SR_LOG_GROUP"
    value     = "${aws_cloudwatch_log_group.survey_runner.name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_ACCESS_KEY_ID"
    value     = "${var.aws_access_key}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_SECRET_ACCESS_KEY"
    value     = "${var.aws_secret_key}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_DEFAULT_REGION"
    value     = "${var.aws_default_region}"
  }

   setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_CLOUDWATCH_LOGGING"
    value     = "${var.cloudwatch_logging}"
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

resource "aws_cloudwatch_log_group" "survey_runner" {
  name = "${var.env}-surveyrunner"
}
