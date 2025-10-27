resource "aws_alb" "ec2_alb" {
  name = "ec2-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.security_group.id]
  subnets = [ 
aws_subnet.sub-pub1.id,
aws_subnet.sub-pub2.id
]

  tags = {
    name = "ecs-alb"
  }
}

resource "aws_lb_target_group" "ec2_tg" {
  name        = "webapp-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
#  vpc_id      = "vpc-068827f882e554167" # VPC default (COMENTAR ESTA LINHA PRA VER O QUE ACONTECE)
  vpc_id      = aws_vpc.main.id # VPC default (COMENTAR ESTA LINHA PRA VER O QUE ACONTECE)

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "ec2_alb_listener" {
  load_balancer_arn = aws_alb.ec2_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward" # ecaminha tráfeto para o TARGET GROUP
    target_group_arn = aws_lb_target_group.ec2_tg.arn
  }
}
