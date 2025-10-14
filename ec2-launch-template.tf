resource "aws_launch_template" "ec2_lt" {
  name_prefix = "ec2-template"
  image_id = ""

  instance_type = "t2.micro"

//essa é uma chave existente mas é possivel criar uma chave
  key_name = "humangov-ec2-key"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  iam_instance_profile {
    name = "ecsInstanceRole"

//“ecsInstanceRole” é uma função predefinida disponível em 
//todas as contas AWS. No entanto, se você quiser usar uma função 
//personalizada, certifique-se de que ela possa acessar o serviço ECS.
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
        Name = "esc_instance"
    }
  } // essa proxima linha tem que criar um arquivo "ecs.sh"
  user_data = filebase64("&(path.module)/ecs.sh")
}


