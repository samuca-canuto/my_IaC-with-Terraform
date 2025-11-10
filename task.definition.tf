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
        value = "http/protobuf"
      },
      {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "https://ingest.us.signoz.cloud:443"
      },
      {
        name  = "SIGNOZ_INGESTION_KEY"
        value = "b4e4cb2f-5337-4c86-a952-793acc1370a3"
      },
      {
        name  = "OTEL_EXPORTER_OTLP_HEADERS"
        value = "signoz-ingestion-key=b4e4cb2f-5337-4c86-a952-793acc1370a3"
      }
    ]
  }
])
