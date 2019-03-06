output "rabbitmq_ip_prime" {
  value = "${element(aws_instance.rabbitmq.*.private_ip, 0)}"
}

output "rabbitmq_ip_failover" {
  value = "${element(aws_instance.rabbitmq.*.private_ip, 1)}"
}
