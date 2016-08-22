resource "aws_elastic_beanstalk_application" "author" {
  name = "${var.env}-author"
  description = "Author Application"
}

resource "aws_elastic_beanstalk_environment" "author-prime" {
  name = "${var.env}-author-prime"
  application = "${aws_elastic_beanstalk_application.author.name}"
  solution_stack_name = "${var.aws_elastic_beanstalk_solution_stack_name}"

  tags {
       Name = "${var.env}-eb-application"
  }

  # Service Role to allow enhanced health check and managed updates
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "aws-elasticbeanstalk-service-role"
  }

  # VPC and Subnet settings
  setting {
    namespace = "aws:ec2:vpc"
    name      =  "VPCId"
    value     = "${aws_vpc.author-vpc.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.author_application.id}"
  }

  # restrict access to the load balancer
  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = "${aws_security_group.author_ons_ips.id}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${aws_security_group.author_ons_ips.id}"
  }

  # allow access to the internet
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "true"
  }

  # EC2 instance role
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${var.elastic_beanstalk_iam_role}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = "${aws_security_group.author_ons_ips.id}"
  }

  # Number of EC2 instances to start the pool with
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

  # The EC2 instance type
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.eb_instance_type}"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "ListenerProtocol"
    value     = "HTTPS"
  }

  # The port for the load balancer to listen on
  setting {
    namespace = "aws:elb:listener:443"
    name      = "SSLCertificateId"
    value     = "${var.certificate_arn}"
  }

  # The port the ec2 instances listens on
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
    value     = "/healthcheck"
  }

  # enable to enhanced health reporting
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

  # Author application specific environment variables.
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_AUTHOR_DATABASE_URL"
    value     = "postgres://${var.database_user}:${var.database_password}@${aws_db_instance.author-database.address}:${aws_db_instance.author-database.port}/${aws_db_instance.author-database.name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_SCHEMA_BUCKET"
    value     = "${var.schema_bucket}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_AUTHOR_ADMIN_USERNAME"
    value     = "${var.author_admin_username}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_AUTHOR_ADMIN_EMAIL"
    value     = "${var.author_admin_email}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_AUTHOR_ADMIN_PASSWORD"
    value     = "${var.author_admin_password}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_AUTHOR_ADMIN_FIRSTNAME"
    value     = "${var.author_admin_firstname}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EQ_AUTHOR_ADMIN_LASTNAME"
    value     = "${var.author_admin_lastname}"
  }
}

resource "aws_route53_record" "author" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.env}-author.${var.dns_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_elastic_beanstalk_environment.author-prime.cname}"]
}
