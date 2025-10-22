resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = [
    aws_subnet.sub-pub1.id,
    aws_subnet.sub-pub2.id
  ]
  desired_capacity = 2
  max_size         = 2
  min_size         = 2

  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }

target_group_arns = [aws_lb_target_group.ec2_tg.arn]

  tag {
    key = "AmazonECSManaged"
    value = true
    propagate_at_launch = true
  }
}
