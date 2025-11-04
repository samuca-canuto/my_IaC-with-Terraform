resource "aws_ecs_task_definition" "ecs_task_definition" {
  family             = "webapp"
  network_mode       = "awsvpc"
  execution_role_arn = "arn:aws:iam::787351301643:role/LabRole" # Verifique se essa role tem permissões ECS Task Execution
  cpu                = 1024

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "webapp-ctr"
      image     = "strm/helloworld-http"
      cpu       = 1024
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
          value = "http://IP_DO_COLLECTOR:4318"
        },
        {
          name  = "OTEL_SERVICE_NAME"
          value = "webapp-ecs"
        },
        {
          name  = "OTEL_EXPORTER_OTLP_PROTOCOL"
          value = "http/protobuf"
        }
      ]
    }
  ])
}
