resource "aws_ecs_service" "ecs_service" {
  name            = "webapp-svc"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 2 # we want to run 2 instances of the container image on our ECS cluster

  network_configuration {
    security_groups    = [aws_security_group.security_group.id]
    subnets = [
      aws_subnet.sub-pub1.id,
      aws_subnet.sub-pub2.id
    ]
  }

  force_new_deployment = true

  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = timestamp()
  }


  load_balancer {
    target_group_arn = aws_lb_target_group.ec2_tg.arn
    container_name   = "webapp-ctr"
    container_port   = 80
  }
}
