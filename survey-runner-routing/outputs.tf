output "private_route_table_ids" {
  value = ["${aws_route_table.private.*.id}"]
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public.*.id}"]
}

output "nat_gateway_ips" {
  value = "${aws_eip.nat_eip.*.public_ip}"
}