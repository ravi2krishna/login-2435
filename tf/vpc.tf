resource "aws_vpc" "lms-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "lms-vpc"
  }
}

resource "aws_subnet" "lms-web-sn" {
  vpc_id     = aws_vpc.lms-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "lms-web-subnet"
  }
}

resource "aws_subnet" "lms-api-sn" {
  vpc_id     = aws_vpc.lms-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "lms-api-subnet"
  }
}

resource "aws_subnet" "lms-db-sn" {
  vpc_id     = aws_vpc.lms-vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "lms-db-subnet"
  }
}

resource "aws_internet_gateway" "lms-igw" {
  vpc_id = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-internet-gateway"
  }
}

resource "aws_route_table" "lms-public-rt" {
  vpc_id = aws_vpc.lms-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lms-igw.id
  }

  tags = {
    Name = "lms-public-rt"
  }
}

resource "aws_route_table_association" "lms-web-asc" {
  subnet_id      = aws_subnet.lms-web-sn.id
  route_table_id = aws_route_table.lms-public-rt.id
}

resource "aws_route_table_association" "lms-api-asc" {
  subnet_id      = aws_subnet.lms-api-sn.id
  route_table_id = aws_route_table.lms-public-rt.id
}

resource "aws_route_table" "lms-private-rt" {
  vpc_id = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-private-rt"
  }
}

resource "aws_route_table_association" "lms-db-asc" {
  subnet_id      = aws_subnet.lms-db-sn.id
  route_table_id = aws_route_table.lms-private-rt.id
}

resource "aws_network_acl" "lms-nacl" {
  vpc_id = aws_vpc.lms-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "lms-nacl"
  }
}

resource "aws_network_acl_association" "lms-web-nacl-asc" {
  network_acl_id = aws_network_acl.lms-nacl.id
  subnet_id      = aws_subnet.lms-web-sn.id
}

resource "aws_network_acl_association" "lms-api-nacl-asc" {
  network_acl_id = aws_network_acl.lms-nacl.id
  subnet_id      = aws_subnet.lms-api-sn.id
}

resource "aws_network_acl_association" "lms-db-nacl-asc" {
  network_acl_id = aws_network_acl.lms-nacl.id
  subnet_id      = aws_subnet.lms-db-sn.id
}