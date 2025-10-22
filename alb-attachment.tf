resource "aws_autoscaling_attachment" "ec2_attach" {
  target_group_arn = aws_lb_target_group.ec2_tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}
