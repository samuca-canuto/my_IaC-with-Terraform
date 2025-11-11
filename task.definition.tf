resource "aws_ecs_task_definition" "ecs_task_definition" {
  family             = "webapp"
  network_mode       = "awsvpc"
  execution_role_arn = "arn:aws:iam::787351301643:role/LabRole"
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
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/webapp"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [
        {
          name  = "OTEL_SERVICE_NAME"
          value = "webapp-ecs"
        },
        {
          name  = "OTEL_EXPORTER_OTLP_PROTOCOL"
          value = "grpc"
        },
        {
          name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
          value = "http://10.0.1.160:4317"
        }
      ]
    }
  ])
}
