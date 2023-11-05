resource "aws_ecs_task_definition" "tech_challenge_task_definition" {
  family                   = "${local.project_name}-task-defintion"
  task_role_arn            = aws_iam_role.tech_challenge_fargate_task_role.arn
  execution_role_arn       = aws_iam_role.tech_challenge_fargate_task_role.arn
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "1024"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name                    = var.container_name
      image                   = "${aws_ecr_repository.tech-challenge-ecr.repository_url}:latest"
      cpu                     = 10
      memory                  = 512
      essential               = true
      log_group               = aws_cloudwatch_log_group.log_group_create.name
      aws_ecs_cluster_fargate = aws_ecs_cluster.tech_challenge_cluster.arn
      execution_role_arn      = aws_iam_role.tech_challenge_fargate_task_role.arn
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      healthCheck = {
        retries = 6
        command = ["CMD-SHELL", "curl -f http://localhost:8080/tech-challenge/health || exit 1"]
        timeout : 2
        interval : 10
        startPeriod : 100
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log_group_create.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "tech-challenge-api-service" {
  name                 = "${local.project_name}-service"
  cluster              = aws_ecs_cluster.tech_challenge_cluster.id
  task_definition      = aws_ecs_task_definition.tech_challenge_task_definition.arn
  desired_count        = 1
  force_new_deployment = false
  launch_type          = "FARGATE"

  network_configuration {
    subnets          = toset(data.aws_subnets.private.ids)
    security_groups  = [aws_security_group.tech_challenge_security_group.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn   = aws_service_discovery_service.service_discovery.arn
    container_name = "${local.project_name}-task-defintion"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tech_challenge_target_group.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  health_check_grace_period_seconds = 110

  depends_on = [aws_ecs_cluster.tech_challenge_cluster, aws_ecs_task_definition.tech_challenge_task_definition]
}

