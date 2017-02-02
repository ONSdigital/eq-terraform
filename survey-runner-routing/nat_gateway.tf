resource "aws_eip" "nat_eip" {
  count = "${length(var.public_cidrs)}"
  vpc   = true
}

resource "aws_nat_gateway" "nat_gw" {
  count         = "${length(var.public_cidrs)}"
  allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on    = ["aws_eip.nat_eip"]
}

resource "aws_route_table" "private" {
  count  = "${length(var.public_cidrs)}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name        = "${var.env}-route-table-private-${count.index+1}"
    Environment = "${var.env}"
    Type        = "Private"
  }
}

resource "aws_route" "private_nat_gateway_route" {
  count                  = "${length(var.public_cidrs)}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = ["aws_route_table.private"]
  nat_gateway_id         = "${element(aws_nat_gateway.nat_gw.*.id, count.index)}"
}

resource "aws_route" "private_vpc_peering_route" {
  count                  = "${(var.vpc_peer_connection_id == "" ? 0 : 1) * length(var.public_cidrs)}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "${var.vpc_peer_cidr_block}"
  vpc_peering_connection_id = "${var.vpc_peer_connection_id}"
  depends_on             = ["aws_route_table.private"]
}
