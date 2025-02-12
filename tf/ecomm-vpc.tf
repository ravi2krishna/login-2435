resource "aws_vpc" "ecomm-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ecomm-vpc"
  }
}

resource "aws_subnet" "ecomm-web-sn" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "ecomm-web-subnet"
  }
}

resource "aws_subnet" "ecomm-api-sn" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "ecomm-api-subnet"
  }
}

resource "aws_subnet" "ecomm-db-sn" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "ecomm-db-subnet"
  }
}

resource "aws_internet_gateway" "ecomm-igw" {
  vpc_id = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-internet-gateway"
  }
}

resource "aws_route_table" "ecomm-public-rt" {
  vpc_id = aws_vpc.ecomm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecomm-igw.id
  }

  tags = {
    Name = "ecomm-public-rt"
  }
}

resource "aws_route_table_association" "ecomm-web-asc" {
  subnet_id      = aws_subnet.ecomm-web-sn.id
  route_table_id = aws_route_table.ecomm-public-rt.id
}

resource "aws_route_table_association" "ecomm-api-asc" {
  subnet_id      = aws_subnet.ecomm-api-sn.id
  route_table_id = aws_route_table.ecomm-public-rt.id
}

resource "aws_route_table" "ecomm-private-rt" {
  vpc_id = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-private-rt"
  }
}

resource "aws_route_table_association" "ecomm-db-asc" {
  subnet_id      = aws_subnet.ecomm-db-sn.id
  route_table_id = aws_route_table.ecomm-private-rt.id
}

resource "aws_network_acl" "ecomm-nacl" {
  vpc_id = aws_vpc.ecomm-vpc.id

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
    Name = "ecomm-nacl"
  }
}

resource "aws_network_acl_association" "ecomm-web-nacl-asc" {
  network_acl_id = aws_network_acl.ecomm-nacl.id
  subnet_id      = aws_subnet.ecomm-web-sn.id
}

resource "aws_network_acl_association" "ecomm-api-nacl-asc" {
  network_acl_id = aws_network_acl.ecomm-nacl.id
  subnet_id      = aws_subnet.ecomm-api-sn.id
}

resource "aws_network_acl_association" "ecomm-db-nacl-asc" {
  network_acl_id = aws_network_acl.ecomm-nacl.id
  subnet_id      = aws_subnet.ecomm-db-sn.id
}

resource "aws_security_group" "ecomm-web-sg" {
  name        = "ecomm-web-sg"
  description = "Allow Web Traffic"
  vpc_id      = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecomm-web-sg-ssh" {
  security_group_id = aws_security_group.ecomm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "ecomm-web-sg-http" {
  security_group_id = aws_security_group.ecomm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_security_group" "ecomm-api-sg" {
  name        = "ecomm-api-sg"
  description = "Allow API Traffic"
  vpc_id      = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-api-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecomm-api-sg-ssh" {
  security_group_id = aws_security_group.ecomm-api-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "ecomm-api-sg-http" {
  security_group_id = aws_security_group.ecomm-api-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_security_group" "ecomm-db-sg" {
  name        = "ecomm-db-sg"
  description = "Allow DB Traffic"
  vpc_id      = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecomm-db-sg-ssh" {
  security_group_id = aws_security_group.ecomm-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "ecomm-db-sg-postgres" {
  security_group_id = aws_security_group.ecomm-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}