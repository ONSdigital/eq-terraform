output "rabbitmq_ip_prime" {
  value = "${aws_instance.rabbitmq.0.private_ip}"
}

output "rabbitmq_ip_failover" {
  value = "${aws_instance.rabbitmq.1.private_ip}"
}