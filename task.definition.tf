resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "webapp"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = "arn:aws:iam::787351301643:role/LabRole"

  container_definitions = jsonencode([{
    name      = "webapp-ctr"
    image     = "strm/helloworld-http"
    essential = true
    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]
  }])
}
