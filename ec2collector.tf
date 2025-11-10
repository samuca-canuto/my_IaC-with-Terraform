resource "aws_instance" "otel_collector" {
  ami                    = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.sub-pub1.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  key_name               = "vockey"
  associate_public_ip_address = true

  tags = {
    Name = "otel-collector-base"
  }
}
