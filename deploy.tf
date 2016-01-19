provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "eu-west-1"
}

resource "aws_instance" "rabbitmq" {
    ami = "ami-47a23a30"
    count = 2
    instance_type = "t2.small"
    key_name = "${var.aws_key_pair}"

    tags {
        Name = "RabbitMQ ${var.env} ${count.index + 1}"
    }

    security_groups = ["${aws_security_group.allow_all.name}"]
}


resource "template_file" "hosts" {
    template = "${file("templates/hosts")}"
    vars= {
        rabbitmq1_ip = "${aws_instance.rabbitmq.0.private_ip}"
        rabbitmq2_ip = "${aws_instance.rabbitmq.1.private_ip}"
        deploy_env    = "${var.env}"
    }
}

resource "null_resource" "aws_hosts" {

    provisioner "local-exec" {
      command = "mkdir -p tmp"
    }

     provisioner "remote-exec" {
        inline = [
            "sudo sh -c 'echo ${var.env}-rabbitmq1 > /etc/hostname'",
            "sudo sh -c '${template_file.hosts.rendered} \n cat /etc/hosts'",
            "sudo hostname -F /etc/hostname"
        ]
        connection {
            type="ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq.0.public_ip}"
            private_key = "${file("pre-prod.pem")}"
            agent = false
        }
    }

     provisioner "remote-exec" {
        inline = [
            "sudo sh -c 'echo ${var.env}-rabbitmq2 > /etc/hostname'",
            "sudo sh -c '${template_file.hosts.rendered} \n cat /etc/hosts'",
            "sudo hostname -F /etc/hostname"
        ]
        connection {
            type="ssh"
            user = "ubuntu"
            host = "${aws_instance.rabbitmq.1.public_ip}"
            private_key = "${file("pre-prod.pem")}"
            agent = false
        }
    }

}

resource "null_resource" "ansible" {
    depends_on = ["null_resource.aws_hosts"]

    provisioner "local-exec" {
      command = "rm -rf tmp"
    }

    provisioner "local-exec" {
      command = "git clone https://github.com/ONSdigital/eq-messaging.git tmp/eq-messaging"
    }

    provisioner "local-exec" {
      command = "ansible-playbook -i '${var.env}-rabbitmq1.eq.ons.digital,${var.env}-rabbitmq2.eq.ons.digital'  --private-key pre-prod.pem tmp/eq-messaging/ansible/rabbitmq-cluster.yml --extra-vars \"deploy_env=${var.env}\""
    }
    # ansible-playbook -i "dan-rabbitmq1.eq.ons.digital,dan-rabbitmq2.eq.ons.digital" --private-key ../eq-terraform/pre-prod.pem -v ansible/rabbitmq-cluster.yml --extra-vars "deploy_env=dan"
    provisioner "local-exec" {
      command = "rm -rf tmp"
    }
}

resource "aws_route53_record" "rabbitmq1" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.env}-rabbitmq1.${var.dns_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_instance.rabbitmq.0.public_dns}"]
}

resource "aws_route53_record" "rabbitmq2" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.env}-rabbitmq2.${var.dns_zone_name}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_instance.rabbitmq.1.public_dns}"]
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
