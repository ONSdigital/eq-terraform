resource "aws_vpc_endpoint" "private_dynamodb" {
  vpc_id       = "${var.vpc_id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  route_table_ids = ["${aws_route_table.private.*.id}"]
}

resource "aws_vpc_endpoint" "private_s3" {
  vpc_id       = "${var.vpc_id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = ["${aws_route_table.private.*.id}"]
}