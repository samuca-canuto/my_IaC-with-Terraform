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
      image     = "otel/opentelemetry-collector-contrib:latest"
      essential = true

      portMappings = [
        {
          containerPort = 4317
          protocol      = "tcp"
        },
        {
          containerPort = 4318
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
          value = "https://ingest.YOUR-ORG.signoz.io:443" # substitua com sua URL do SigNoz Cloud ou IP on-prem
        },
        {
          name  = "OTEL_EXPORTER_OTLP_HEADERS"
          value = "signoz-access-token=YOUR_TOKEN" # substitua com seu token do SigNoz Cloud
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
    }
  ])
}
