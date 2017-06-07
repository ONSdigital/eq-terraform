resource "aws_elastic_beanstalk_application" "survey_runner" {
  name        = "${var.env}-survey-runner"
  description = "Survey runner for ${var.env}"
}

resource "aws_elastic_beanstalk_environment" "survey_runner_prime" {
  name                = "${var.env}-prime"
  application         = "${aws_elastic_beanstalk_application.survey_runner.name}"
  solution_stack_name = "${var.aws_elastic_beanstalk_solution_stack_name}"
  wait_for_ready_timeout = "20m"

  # The configuration settings for this section can be found here


  # http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html


  # They are listed for cloud formation but can be easily converted to terraform


  # essentially everything is namespaced with a name and value

  # settings below tell elastic beanstalk to deploy into our VPC
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", aws_subnet.application.*.id)}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${var.use_internal_elb ? join(",", aws_subnet.application.*.id) : join(",", var.public_subnet_ids)}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "${var.use_internal_elb ? "internal" : "external" }"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "aws-elasticbeanstalk-service-role"
  }
  # Application Deployments
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Immutable"
  }
  # Configuration Updates
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "true"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Immutable"
  }
  # This setting restricts the IP range that can access elastic beanstalk
  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = "${aws_security_group.survey_runner_access.id}"
  }
  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = "${aws_security_group.survey_runner_access.id}"
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
    value     = "${aws_security_group.survey_runner_access.id}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.elasticbeanstalk_survey_runner.name}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.eb_instance_type}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "MonitoringInterval"
    value     = "1 minute"
  }
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
  # The port the load balancer will route traffic to
  # (LB listens on 443, terminates SSL and forwards to the EC2 instances on port 80)
  setting {
    namespace = "aws:elb:listener:443"
    name      = "InstancePort"
    value     = "80"
  }
  setting {
    namespace = "aws:elb:listener:443"
    name      = "InstanceProtocol"
    value     = "HTTP"
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
  # time is UTC
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = "Tue:02:00"
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
    name      = "EQ_RABBITMQ_URL"
    value     = "${var.rabbitmq_ip_prime}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_RABBITMQ_URL_SECONDARY"
    value     = "${var.rabbitmq_ip_failover}"
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
    name      = "EQ_SERVER_SIDE_STORAGE_DATABASE_HOST"
    value     = "${var.database_address}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_LOG_LEVEL"
    value     = "${var.eq_log_level}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_DEFAULT_REGION"
    value     = "${var.aws_default_region}"
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
    namespace = "aws:elasticbeanstalk:container:python"
    name      = "NumProcesses"
    value     = "${var.wsgi_number_of_processes}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:python"
    name      = "NumThreads"
    value     = "${var.wsgi_number_of_threads}"
  }
  # Cloudwatch log streaming
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "30"
  }
  # Autoscaling triggers
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = "CPUUtilization"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = "Average"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = "Percent"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Period"
    value     = "1"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "BreachDuration"
    value     = "1"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = "40"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperBreachScaleIncrement"
    value     = "1"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold"
    value     = "20"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerBreachScaleIncrement"
    value     = "-1"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Cooldown"
    value     = "60"
  }
  setting {
    namespace = "aws:elb:policies"
    name      = "ConnectionDrainingEnabled"
    value     = "true"
  }
  setting {
    namespace = "aws:elb:policies"
    name      = "ConnectionDrainingTimeout"
    value     = "20"
  }
  setting {
    namespace = "aws:elb:healthcheck"
    name      = "HealthyThreshold"
    value     = "2"
  }
  setting {
    namespace = "aws:elb:healthcheck"
    name      = "Interval"
    value     = "5"
  }
  setting {
    namespace = "aws:elb:healthcheck"
    name      = "Timeout"
    value     = "3"
  }
  setting {
    namespace = "aws:elb:healthcheck"
    name      = "UnhealthyThreshold"
    value     = "2"
  }
}

resource "aws_route53_record" "survey_runner" {
  count   = "${var.use_internal_elb ? 0 : 1}"
  zone_id = "${var.dns_zone_id}"
  name    = "${var.env}-surveys.${var.dns_zone_name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_elastic_beanstalk_environment.survey_runner_prime.cname}"]
}
