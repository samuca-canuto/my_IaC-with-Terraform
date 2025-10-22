resource "aws_launch_template" "ec2_lt" {
  name_prefix = "ec2-template"
  image_id = "ami-0c02fb55956c7d316"  # Amazon Linux 2 (us-east-1)



  instance_type = "t2.micro"

//essa é uma chave existente mas é possivel criar uma chave
  key_name = "vockey"
  vpc_security_group_ids = [aws_security_group.security_group.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
        Name = "ec2_instance"
    }
  } 
  user_data = base64encode(<<EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
echo "<h1>Infra funcionando direto na EC2!</h1>" > /var/www/html/index.html
EOF
)
}


