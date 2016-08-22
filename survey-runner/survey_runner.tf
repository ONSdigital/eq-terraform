resource "aws_elastic_beanstalk_application" "surveyrunner" {
  name = "${var.env}-surveyrunner"
  description = "Survey runner for environment"
}

resource "aws_elastic_beanstalk_environment" "sr_prime" {
  name = "${var.env}-prime"
  application = "${aws_elastic_beanstalk_application.surveyrunner.name}"
  solution_stack_name = "${var.aws_elastic_beanstalk_solution_stack_name}"

  # The configuration settings for this section can be found here
  # http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html
  # They are listed for cloud formation but can be easily converted to terraform
  # essentially everything is namespaced with a name and value

  # settings below tell elastic beanstalk to deploy into our VPC
  setting {
    namespace = "aws:ec2:vpc"
    name      =  "VPCId"
    value     = "${aws_vpc.survey_runner_default.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.sr_application.id}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "aws-elasticbeanstalk-service-role"
  }

  # this setting restricts the IP range that can access elastic beanstalk
  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = "${aws_security_group.survey_runner_ons_ips.id}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = "${aws_security_group.survey_runner_ons_ips.id}"
  }

  # this setting allows SSH access to the ec2 instances running elastic beanstalk (note this should be blank in prod)
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.elastic_beanstalk_aws_key_pair}"
  }

  # security groups for the EC2 instances
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${aws_security_group.survey_runner_vpn_services_logging_auditing.id},${aws_security_group.survey_runner_ons_ips.id}"
  }

  # allows elastic beanstalk to access the outside world
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "true"
  }

  # the instance role for elastic beanstalk
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${var.elastic_beanstalk_iam_role}"
  }

  # Number of EC2 servers to start with (min & max)
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.eb_min_size}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.eb_max_size}"
  }

  # The type of EC2 instance to launch
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.eb_instance_type}"
  }

  # The listener protocol for the Elastic beanstalk load balancer
  setting {
    namespace = "aws:elb:listener:443"
    name      = "ListenerProtocol"
    value     = "HTTPS"
  }

  # The certificate to enable SSL on the load balancers
  setting {
    namespace = "aws:elb:listener:443"
    name      = "SSLCertificateId"
    value     = "${var.certificate_arn}"
  }

  # The port the load balancer will route traffic to
  # (LB listens on 443, terminates SSL and forwards to the EC2 instances on port 80)
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

  # Healthcheck settings for elastic beanstalk
  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "/status"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  # Managed updates setting, basically all EC2 instances are refreshed and updated weekly on Tuesday at 3am
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = "Tue:03:00"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = "minor"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "InstanceRefreshEnabled"
    value     = "true"
  }

  # Survey Runner Application Specific Environment variables
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
    value     = "amqp://${var.rabbitmq_write_user}:${var.rabbitmq_write_password}@${aws_instance.rabbitmq.0.private_ip}:5672/%2F"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_RABBITMQ_URL_SECONDARY"
    value     = "amqp://${var.rabbitmq_write_user}:${var.rabbitmq_write_password}@${aws_instance.rabbitmq.1.private_ip}:5672/%2F"
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
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_DEV_MODE"
    value     = "${var.dev_mode}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_SCHEMA_BUCKET"
    value     = "${var.schema_bucket}"
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
    value     = "postgresql://${var.database_user}:${var.database_password}@${aws_db_instance.survey_runner_database.address}:${aws_db_instance.survey_runner_database.port}/${aws_db_instance.survey_runner_database.name}"
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
