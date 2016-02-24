resource "aws_instance" "rabbitmq" {
    ami = "ami-47a23a30"
    count = 2
    instance_type = "${var.rabbitmq_instance_type}"
    key_name = "${var.aws_key_pair}"
    subnet_id = "${aws_subnet.default.id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.default.id}"]

    tags {
        Name = "RabbitMQ ${var.env} ${count.index + 1}"
    }
}

resource "aws_elb" "rabbitmq" {
  name = "${var.env}-rabbitmq-elb"
  subnets = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.default.id}"]
  internal = true

  listener {
    instance_port = 5672
    instance_protocol = "TCP"
    lb_port = 5672
    lb_protocol = "TCP"
  }
  listener {
    instance_port = 5673
    instance_protocol = "TCP"
    lb_port = 5673
    lb_protocol = "TCP"
  }

  instances = ["${aws_instance.rabbitmq.0.id}", "${aws_instance.rabbitmq.1.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "${var.env}-rabbitmq-elb"
  }
}


resource "aws_route53_record" "rabbitmq" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.env}-rabbitmq.${var.dns_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_elb.rabbitmq.dns_name}"]
}


resource "template_file" "hosts" {
    template = "${file("templates/hosts")}"
    vars= {
        rabbitmq1_ip = "${aws_instance.rabbitmq.0.private_ip}"
        rabbitmq2_ip = "${aws_instance.rabbitmq.1.private_ip}"
        deploy_env   = "${var.env}"
        deploy_dns    = "${var.dns_zone_name}"
    }
}

resource "null_resource" "aws_hosts" {

    provisioner "local-exec" {
      command = "mkdir -p tmp"
    }

    provisioner "local-exec" {
      command = "echo '${template_file.hosts.rendered}' > tmp/hosts"
    }

    provisioner "file" {
        source = "tmp/hosts"
        destination = "/home/ubuntu/hosts"
        connection {
            type="ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq.0.public_ip}"
            private_key = "${file("${var.aws_key_pair}.pem")}"
            agent = false
        }
    }

    provisioner "file" {
        source = "tmp/hosts"
        destination = "/home/ubuntu/hosts"
        connection {            type = "ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq.1.public_ip}"
            private_key = "${file("${var.aws_key_pair}.pem")}"
            agent = false
        }
    }

    provisioner "remote-exec" {
        inline = [
            "sudo sh -c 'echo ${var.env}-rabbitmq1 > /etc/hostname'",
            "sudo cp hosts /etc/hosts",
            "sudo hostname -F /etc/hostname"
        ]
        connection {
            type="ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq.0.public_ip}"
            private_key = "${file("${var.aws_key_pair}.pem")}"
            agent = false
        }
    }

     provisioner "remote-exec" {
        inline = [
            "sudo sh -c 'echo ${var.env}-rabbitmq2 > /etc/hostname'",
            "sudo cp hosts /etc/hosts",
            "sudo hostname -F /etc/hostname"
        ]
        connection {
            type="ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq.1.public_ip}"
            private_key = "${file("${var.aws_key_pair}.pem")}"
            agent = false
        }
    }

}

resource "null_resource" "ansible" {
    depends_on = ["null_resource.aws_hosts", "aws_route53_record.rabbitmq1", "aws_route53_record.rabbitmq2"]

    provisioner "local-exec" {
      command = "rm -rf tmp"
    }

    provisioner "local-exec" {
      command = "git clone https://github.com/ONSdigital/eq-messaging.git tmp/eq-messaging"
    }

    provisioner "local-exec" {
      command = "ansible-playbook -i '${var.env}-rabbitmq1.${var.dns_zone_name},${var.env}-rabbitmq2.${var.dns_zone_name}'  --private-key ${var.aws_key_pair}.pem tmp/eq-messaging/ansible/rabbitmq-cluster.yml --extra-vars '{\"deploy_env\":\"${var.env}\",\"deploy_dns\":\"${var.dns_zone_name}\",\"rabbitmq_admin_user\":\"${var.rabbitmq_admin_user}\",\"rabbitmq_admin_password\":\"${var.rabbitmq_admin_password}\",\"rabbitmq_write_user\":\"${var.rabbitmq_write_user}\",\"rabbitmq_write_password\":\"${var.rabbitmq_write_password}\",\"rabbitmq_read_user\":\"${var.rabbitmq_read_user}\",\"rabbitmq_read_password\":\"${var.rabbitmq_read_password}\"}'"
    }
    provisioner "local-exec" {
      command = "rm -rf tmp"
    }
}

resource "aws_route53_record" "rabbitmq1" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.env}-rabbitmq1.${var.dns_zone_name}"
  type = "A"
  ttl = "60"
  records = ["${aws_instance.rabbitmq.0.public_ip}"]
}

resource "aws_route53_record" "rabbitmq2" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.env}-rabbitmq2.${var.dns_zone_name}"
  type = "A"
  ttl = "60"
  records = ["${aws_instance.rabbitmq.1.public_ip}"]
}

resource "aws_security_group" "allow_all" {
  name = "${var.env}-allow_all"
  description = "Allow all inbound traffic"

    ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        Name = "Terraform Allow All"
    }
}
