resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = [
    aws_subnet.sub-pub1.id,
   // não sei se essa linha a seguir deve existir, pq as subs do tutorial sao duas duas
   //pblicas, e a gente tem apenas uma publica 
   //o auto scaling age apenas na priv
   // aws_subnet.subnet2.id
  ]
  desired_capacity = 2
  max_size         = 2
  min_size         = 2

  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }
  
  tag {
    key = "AmazonECSManaged"
    value = true
    propagate_at_launch = true
  }
}