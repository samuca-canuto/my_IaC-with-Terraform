resource "aws_key_pair" "ssh_key" {
  key_name   = "cockroach-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "cockroach_sg" {
  name   = "cockroach-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Cockroach SQL"
    from_port   = 26257
    to_port     = 26257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "Cockroach Admin UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cockroach" {
  ami           = "ami-0c7217cdde317cfec" # Amazon Linux 2023
  instance_type = "t3.micro"
  key_name      = aws_key_pair.ssh_key.key_name
  subnet_id     =  aws_subnet.sub-pub1.id

  vpc_security_group_ids = [aws_security_group.cockroach_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y wget
    wget https://binaries.cockroachdb.com/cockroach-v23.2.4.linux-amd64.tgz
    tar xzf cockroach-*.tgz
    cp cockroach-*/cockroach /usr/local/bin

    mkdir /var/lib/cockroach
    cockroach start-single-node \
      --insecure \
      --listen-addr=0.0.0.0 \
      --http-addr=0.0.0.0:8080 \
      --store=/var/lib/cockroach \
      --background
  EOF

  tags = {
    Name = "cockroach-single-node"
  }
}

output "cockroach_public_ip" {
  value = aws_instance.cockroach.private_ip
}
