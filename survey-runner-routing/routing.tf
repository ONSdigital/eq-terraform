resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name        = "${var.env}-route-table-public"
    Environment = "${var.env}"
    Type        = "Public"
  }
}

# Public subnet for NAT gateway and internet gateway
resource "aws_subnet" "public" {
  count             = "${length(var.public_cidrs)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.public_cidrs[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags {
    Name        = "${var.env}-public-subnet-${count.index+1}"
    Environment = "${var.env}"
    Type        = "Public"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_cidrs)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"

  tags {
    Environment = "${var.env}"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${var.internet_gateway_id}"

  tags {
    Environment = "${var.env}"
  }
}
