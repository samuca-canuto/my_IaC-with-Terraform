resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    name = "main"
  }
}

resource "aws_subnet" "sub-pub1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "sub-priv1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "sub-pub2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "sub-priv2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"
}


resource "aws_internet_gateway" "igw" {  //decalra;'ao do igw
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_eip" "nat_eip" { //elastic ip para o nat
//  vpc = true
}

resource "aws_nat_gateway" "nat" { //declara;'ao do nat
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.sub-pub1.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

//Nessa rota apontamos a sub_pub para o igw (e para mais algum lugar?)
resource "aws_route_table_association" "pub_association" { 
    subnet_id = aws_subnet.sub-pub1.id
    route_table_id = aws_route_table.public_rt.id
}

//NEssa rota temos que apontar a sub_priv para o NAT (e para mais algum lugar?)
resource "aws_route_table_association" "priv_association" {
  subnet_id      = aws_subnet.sub-priv1.id
  route_table_id = aws_route_table.private_rt.id
}

// Associa a nova subnet pública à route table pública
resource "aws_route_table_association" "pub_association_2" {
  subnet_id      = aws_subnet.sub-pub2.id
  route_table_id = aws_route_table.public_rt.id
}

// Associa a nova subnet privada à route table privada
resource "aws_route_table_association" "priv_association_2" {
  subnet_id      = aws_subnet.sub-priv2.id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_security_group" "security_group" { 
    vpc_id = aws_vpc.main.id

    ingress { 
        from_port = 0
        to_port = 0
        protocol = "-1" 
        self = "false"
        cidr_blocks = [ "0.0.0.0/0" ] 
        description = "any"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}
