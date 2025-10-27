resource "aws_ecs_service" "ecs_service" {
  name            = "webapp-svc"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.security_group.id]
    subnets = [
      aws_subnet.sub-pub1.id,
      aws_subnet.sub-pub2.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ec2_tg.arn
    container_name   = "webapp-ctr"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.ec2_alb_listener
  ]
}
