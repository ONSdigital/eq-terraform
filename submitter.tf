resource "template_file" "submitter_user_data" {
    template = "${file("templates/env_ec2_variables_submitter.sh.tpl")}"

    vars {
          rabbitmq_url = "${aws_elb.rabbitmq.dns_name}"
          rabbitmq_queue = "${var.message_queue_name}"
          submissions_bucket_name = "${var.submissions_bucket_name}"
          # These are only for the submitter use
          aws_access_key = "${var.sub_aws_access_key}"
          aws_secret_access_key = "${var.sub_aws_secret_key}"

    }
}

resource "aws_instance" "submitter" {
    ami = "ami-47a23a30"
    count = 2
    instance_type = "t2.medium"
    key_name = "${var.aws_key_pair}"
    subnet_id = "${aws_subnet.default.id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.default.id}"]
    user_data = "${template_file.submitter_user_data.rendered}"


    tags {
      Name = "Submitter ${var.env} ${count.index + 1}"
    }

    provisioner "remote-exec" {
        connection {
            user = "ubuntu"
            private_key = "${var.aws_key_pair}.pem"
        }
        script = "deploy_submitter.sh"
    }
}
