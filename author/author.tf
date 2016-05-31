resource "aws_elastic_beanstalk_application" "author" {
  name = "${var.env}-author"
  description = "Author for environment"
}

resource "aws_elastic_beanstalk_environment" "author-prime" {
  name = "${var.env}-author-prime"
  application = "${aws_elastic_beanstalk_application.author.name}"
  solution_stack_name = "${var.aws_elastic_beanstalk_solution_stack_name}"

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
    value     = "${aws_security_group.author_ons_ips.id}"
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
    namespace = "aws:elb:listener:80"
    name      = "ListenerProtocol"
    value     = "HTTP"
  }

  setting {
    namespace =  "aws:elb:listener:80"
    name      = "InstancePort"
    value = "80"
  }

  setting {
    namespace  = "aws:elb:listener:80"
    name       = "InstanceProtocol"
    value      = "HTTP"
  }
}


resource "aws_route53_record" "author" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.env}-author.${var.dns_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_elastic_beanstalk_environment.author-prime.cname}"]
}
