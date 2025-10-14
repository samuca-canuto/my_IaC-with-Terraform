resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    name = "main"
  }
}

resource "aws_subnet" "sub-pub1" {
  vpc_id = aws_vpc.main.id
//cidr_block = 
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "sub-priv1" {
  vpc_id = aws_vpc.main.id
//cidr_block = 
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
}

/*resource "aws_subnet" "sub-pub2" {
  vpc_id = aws_vpc.main.id
//cidr_block = 
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "sub-priv2" {
  vpc_id = aws_vpc.main.id
//cidr_block = 
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1b"
}
*/

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

//Nessa rota apontamos a sub_pub para o igw (e para mais algum lugar?)
resource "aws_route_table_association" "subnetpub_route" { 
    subnet_id = aws_subnet.sub-pub1.id
    route_table_id = aws_route_table.route_table.id
}

//NEssa rota temos que apontar a sub_priv para o NAT (e para mais algum lugar?)
resource "aws_route_table_association" "subnetpriv_route" { 
    subnet_id = aws_subnet.sub-priv1.id
    route_table_id = aws_route_table.route_table.id
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
