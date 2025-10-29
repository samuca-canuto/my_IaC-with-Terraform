resource "aws_ecs_service" "otel_collector_svc" {
  name            = "otel-collector-svc"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.otel_collector.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.security_group.id]
    subnets = [
      aws_subnet.sub-pub1.id,
      aws_subnet.sub-pub2.id
    ]
  }
}
