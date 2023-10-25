resource "aws_ecs_cluster" "tech-challenge-cluster" {
    name = "tech-challenge-cluster"

    tags = {
        Name = var.tag
    }
}

resource "aws_ecs_task_definition" "tech-challenge-task" {
    family                   = "tech-challenge-api"
    task_role_arn            = "${aws_iam_role.ecs_task_role.arn}"
    execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
    network_mode             = "awsvpc"
    cpu                      = "256"
    memory                   = "1024"
    requires_compatibilities = ["FARGATE"]

    container_definitions = jsonencode([
    {
      name      = "tech-challenge-container"
      image     = "${aws_ecr_repository.tech-challenge-ecr.arn}:develop-latest"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "tech-challenge-api-service" {
  name            = "tech-challenge-api-service"
  cluster         = aws_ecs_cluster.tech-challenge-cluster.id
  task_definition = aws_ecs_task_definition.tech-challenge-task.arn
  desired_count   = 1
  network_configuration {
    subnets = [aws_subnet.ecs-public-subnet.id, aws_subnet.ecs-private-subnet.id]
  }
  depends_on = [ aws_ecs_cluster.tech-challenge-cluster, aws_ecs_task_definition.tech-challenge-task ]
}

###### NETWORK

resource "aws_vpc" "ecs-vpc" {
    cidr_block = "172.16.0.0/16"
    enable_dns_hostnames = true
    tags = {
        Name = var.tag
    }
}

resource "aws_subnet" "ecs-public-subnet" {
    vpc_id            = aws_vpc.ecs-vpc.id
    cidr_block        = "172.16.10.0/24"

    tags = {
        Name = var.tag
    }
}

resource "aws_subnet" "ecs-private-subnet" {
    vpc_id            = aws_vpc.ecs-vpc.id
    cidr_block        = "172.16.100.0/24"

    tags = {
        Name = var.tag
    }
}


######IAM
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "role-name"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
resource "aws_iam_role" "ecs_task_role" {
  name = "role-name-task"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "task_s3" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}