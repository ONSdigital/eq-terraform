resource "aws_instance" "rabbitmq" {
  ami                         = "ami-47a23a30"
  iam_instance_profile        = "${aws_iam_instance_profile.rabbitmq-instance-profile.name}"
  count                       = 2
  instance_type               = "${var.rabbitmq_instance_type}"
  key_name                    = "${var.aws_key_pair}"
  subnet_id                   = "${aws_subnet.queue.id}"
  private_ip                  = "${var.rabbitmq_ips[count.index]}"
  associate_public_ip_address = true
  user_data = "${element(template_file.rabbitmq_setup.*.rendered, count.index)}"

  vpc_security_group_ids = ["${aws_security_group.rabbit_required.id}",
    "${aws_security_group.provision-allow-ssh-REMOVE.id}",
    "${aws_security_group.survey_runner_vpn_services_logging_auditing.id}",
    "${aws_security_group.survey_runner_vpn_sdx_access.id}",
  ]

  root_block_device {
    delete_on_termination = "${var.delete_volume_on_termination}"
  }

  tags {
    Name = "${var.env}-rabbitmq-${count.index + 1}"
  }
}

resource "template_file" "hosts" {
  template = "${file("templates/hosts")}"

  vars = {
    rabbitmq1_ip = "${var.rabbitmq_ips[0]}"
    rabbitmq2_ip = "${var.rabbitmq_ips[1]}"
    deploy_env   = "${var.env}"
    deploy_dns   = "${var.dns_zone_name}"
  }
}

resource "template_file" "rabbitmq_setup" {
  template = "${file("templates/rabbitmq_setup")}"
  count = 2

  vars = {
    hosts = "${template_file.hosts.rendered}"
    hostname = "${var.env}-rabbitmq${count.index + 1}"
  }
}

resource "null_resource" "ansible" {
  depends_on = [
    "aws_instance.rabbitmq",
    "aws_route53_record.rabbitmq"
  ]

  provisioner "local-exec" {
    command = "rm -rf tmp"
  }

  provisioner "local-exec" {
    command = "git clone https://github.com/ONSdigital/eq-messaging.git tmp/eq-messaging"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${var.env}-rabbitmq1.${var.dns_zone_name},${var.env}-rabbitmq2.${var.dns_zone_name}'  --private-key ${var.aws_key_pair}.pem tmp/eq-messaging/ansible/rabbitmq-cluster.yml --extra-vars '{\"deploy_env\":\"${var.env}\",\"deploy_dns\":\"${var.dns_zone_name}\",\"rabbitmq_admin_user\":\"${var.rabbitmq_admin_user}\",\"rabbitmq_admin_password\":\"${var.rabbitmq_admin_password}\",\"rabbitmq_write_user\":\"${var.rabbitmq_write_user}\",\"rabbitmq_write_password\":\"${var.rabbitmq_write_password}\",\"rabbitmq_read_user\":\"${var.rabbitmq_read_user}\",\"rabbitmq_read_password\":\"${var.rabbitmq_read_password}\", \"rsyslogd_server_IP\":\"${var.rsyslogd_server_ip}\", \"region\":\"${var.aws_default_region}\"}'"
  }

  provisioner "local-exec" {
    command = "rm -rf tmp"
  }

  triggers = {
      instance_change = "${join(" ", aws_instance.rabbitmq.*.id)}"
  }
}

resource "aws_route53_record" "rabbitmq" {
  count   = 2
  zone_id = "${var.dns_zone_id}"
  name    = "${var.env}-rabbitmq${count.index + 1}.${var.dns_zone_name}"
  type    = "A"
  ttl     = "60"
  records = ["${element(aws_instance.rabbitmq.*.public_ip,count.index)}"]
}
