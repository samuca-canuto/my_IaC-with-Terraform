resource "aws_ecs_task_definition" "otel_collector" {
  family                   = "otel-collector"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::787351301643:role/LabRole"

  container_definitions = jsonencode([
    {
      name      = "otel-collector"
      image     = "787351301643.dkr.ecr.us-east-1.amazonaws.com/otel-tarde:latest"
      essential = true

      portMappings = [
        {
          containerPort = 4317
          hostPort      = 4317
          protocol      = "tcp"
        },
        {
          containerPort = 4318
          hostPort      = 4318
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
          value = "https://ingest.us.signoz.cloud:443"
        },
        {
          name  = "OTEL_EXPORTER_OTLP_HEADERS"
          value = "signoz-access-token=8I6KAHm4A-32OY9kN0tKU7dxtEz4vOTxAHzl"
        },
        {
          name  = "OTEL_RESOURCE_ATTRIBUTES"
          value = "service.name=otel-collector"
        },
        {
          name  = "OTEL_LOG_LEVEL"
          value = "info"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/otel-collector"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
