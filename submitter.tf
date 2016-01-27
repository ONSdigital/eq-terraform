resource "aws_instance" "submitter" {
    ami = "ami-47a23a30"
    count = 2
    instance_type = "t2.small"
    key_name = "${var.aws_key_pair}"
    subnet_id = "${aws_subnet.default.id}"
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.default.id}"]

    tags {
      Name = "Submitter ${var.env} ${count.index + 1}"
    }
}
