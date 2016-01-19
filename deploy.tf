provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "eu-west-1"
}

resource "aws_instance" "rabbitmq1" {
    ami = "ami-47a23a30"
    instance_type = "t2.small"
    key_name = "${var.aws_key_pair}"

    tags {
        Name = "RabbitMQ 1"
    }

    security_groups = ["${aws_security_group.allow_all.name}"]
}


resource "aws_instance" "rabbitmq2" {
    ami = "ami-47a23a30"
    instance_type = "t2.small"
    key_name = "${var.aws_key_pair}"

    tags {
        Name = "RabbitMQ 2"
    }

    security_groups = ["${aws_security_group.allow_all.name}"]

}

resource "template_file" "hosts" {
    template = "${file("templates/hosts")}"
    vars= {
        rabbitmq1_ip = "${aws_instance.rabbitmq1.private_ip}"
        rabbitmq2_ip = "${aws_instance.rabbitmq2.private_ip}"
    }
}

resource "template_file" "hostname-rabbitmq1" {
    template = "${file("templates/hostname")}"
    vars {
        hostname = "rabbitmq1"
    }
}

resource "template_file" "hostname-rabbitmq2" {
    template = "${file("templates/hostname")}"
    vars {
        hostname = "rabbitmq2"
    }
}

resource "null_resource" "aws_hosts" {

    provisioner "local-exec" {
      command = "mkdir tmp"
    }

    provisioner "local-exec" {
        command = "echo '${template_file.hosts.rendered}' > tmp/hosts"
    }

    provisioner "local-exec" {
        command = "echo ${template_file.hostname-rabbitmq1.rendered} > tmp/hostname-rabbitmq1"
    }

    provisioner "local-exec" {
        command = "echo ${template_file.hostname-rabbitmq2.rendered} > tmp/hostname-rabbitmq2"
    }

    provisioner "file" {
        source = "tmp/hosts"
        destination = "/home/ubuntu/hosts"
        connection {
            type="ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq1.public_ip}"
            private_key = "${file("pre-prod.pem")}"
            agent = false
        }
    }

    provisioner "file" {
        source = "tmp/hostname-rabbitmq1"
        destination = "/home/ubuntu/hostname"
        connection {
            type = "ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq1.public_ip}"
            private_key = "${file("pre-prod.pem")}"
            agent = false
        }
    }

    provisioner "file" {
        source = "tmp/hosts"
        destination = "/home/ubuntu/hosts"
        connection {            type = "ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq2.public_ip}"
            private_key = "${file("pre-prod.pem")}"
            agent = false
        }
    }

    provisioner "file" {
        source = "tmp/hostname-rabbitmq2"
        destination = "/home/ubuntu/hostname"
        connection {
            type="ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq2.public_ip}"
            private_key = "${file("pre-prod.pem")}"
            agent = false
        }
    }

     provisioner "remote-exec" {
        inline = [
            "sudo cp hostname /etc/hostname",
            "sudo cp hosts /etc/hosts",
            "sudo hostname -F /etc/hostname"
        ]
        connection {
            type="ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq1.public_ip}"
            private_key = "${file("pre-prod.pem")}"
            agent = false
        }
    }

     provisioner "remote-exec" {
        inline = [
            "sudo cp hostname /etc/hostname",
            "sudo cp hosts /etc/hosts",
            "sudo hostname -F /etc/hostname"
        ]
        connection {
            type="ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq2.public_ip}"
            private_key = "${file("pre-prod.pem")}"
            agent = false
        }
    }

}

resource "null_resource" "ansible" {
   depends_on = ["null_resource.aws_hosts"]

   provisioner "local-exec" {
        command = "git clone https://github.com/ONSdigital/eq-messaging.git tmp/eq-messaging"
    }

    provisioner "local-exec" {
        command = "ansible-playbook --private-key pre-prod.pem tmp/eq-messaging/ansible/rabbitmq-cluster.yml"
    }

    provisioner "local-exec" {
      command = "rm -rf tmp"
    }
}

resource "aws_route53_record" "rabbitmq1" {
  zone_id = "${var.dns_zone_id}"
  name = "rabbitmq1.${var.dns_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_instance.rabbitmq1.public_dns}"]
}

resource "aws_route53_record" "rabbitmq2" {
  zone_id = "${var.dns_zone_id}"
  name = "rabbitmq2.${var.dns_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_instance.rabbitmq2.public_dns}"]
}

resource "aws_security_group" "allow_all" {
  name = "allow_all"
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

