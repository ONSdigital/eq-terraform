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
    value     = "${aws_subnet.sr_application.id}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = "${aws_security_group.ons_ips.id}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${aws_security_group.vpn_services_logging_auditing.id},${aws_security_group.ons_ips.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "true"
  }

   setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${var.elastic_beanstalk_iam_role}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = "${aws_security_group.ons_ips.id}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_SECRET_KEY"
    value     = "${var.application_secret_key}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SR_ENVIRONMENT"
    value     = "${var.survey_runner_env}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_RABBITMQ_URL"
    value     = "amqp://${var.rabbitmq_write_user}:${var.rabbitmq_write_password}@${aws_elb.rabbitmq.dns_name}:5672/%2F"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_RABBITMQ_QUEUE_NAME"
    value     = "${var.message_queue_name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_RABBITMQ_TEST_QUEUE_NAME"
    value     = "${var.message_test_queue_name}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.eb_max_size}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.eb_min_size}"
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
    name      = "AWS_DEFAULT_REGION"
    value     = "${var.aws_default_region}"
  }

   setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_CLOUDWATCH_LOGGING"
    value     = "${var.cloudwatch_logging}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_UA_ID"
    value     = "${var.google_analytics_code}"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "ListenerProtocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "SSLCertificateId"
    value     = "${var.certificate_arn}"
  }

  setting {
    namespace =  "aws:elb:listener:443"
    name      = "InstancePort"
    value = "80"
  }

  setting {
    namespace  = "aws:elb:listener:443"
    name       = "InstanceProtocol"
    value      = "HTTP"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_DEV_MODE"
    value     = "${var.dev_mode}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_SERVER_SIDE_STORAGE"
    value     = "${var.eq_server_side_storage}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_SERVER_SIDE_STORAGE_ENCRYPTION"
    value     = "${var.eq_server_side_storage_encryption}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_SERVER_SIDE_STORAGE_TYPE"
    value     = "${var.eq_server_side_storage_type}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_SERVER_SIDE_STORAGE_DATABASE_URL"
    value     = "postgresql://${var.database_user}:${var.database_password}@${aws_db_instance.database.address}:${aws_db_instance.database.port}/${aws_db_instance.database.name}"
  }

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
