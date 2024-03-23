resource "aws_vpc" "tech_challenge_ecs_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  tags                 = var.tag
}

resource "aws_subnet" "ecs_private_subnet_1" {
  vpc_id            = aws_vpc.tech_challenge_ecs_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = data.aws_availability_zones.non_local.names[0]
  tags = merge(
    var.tag,
    {
      Tier = "private"
    }
  )
}

resource "aws_subnet" "ecs_private_subnet_2" {
  vpc_id            = aws_vpc.tech_challenge_ecs_vpc.id
  cidr_block        = "172.16.100.0/24"
  availability_zone = data.aws_availability_zones.non_local.names[1]

  tags = merge(
    var.tag,
    {
      Tier = "private"
    }
  )
}

resource "aws_db_subnet_group" "tech_challenge_subnet_group" {
  name       = "${local.project_name}-subnet-group"
  subnet_ids = data.aws_subnets.private.ids

  tags = merge(
    var.tag,
    {
      Tier = "private"
    }
  )
}

resource "aws_route_table" "tech_challenge_route_table" {
  vpc_id = aws_vpc.tech_challenge_ecs_vpc.id

  tags = merge(
    var.tag,
    {
      Name = "apigateway-vpc-endpoint"
    }
  )
  depends_on = [aws_vpc.tech_challenge_ecs_vpc]
}

resource "aws_route_table_association" "private" {
  count          = length(data.aws_subnets.private)
  subnet_id      = element(data.aws_subnets.private.ids, count.index)
  route_table_id = aws_route_table.tech_challenge_route_table.id
}

data "aws_vpc" "selected" {
  id = aws_vpc.tech_challenge_ecs_vpc.id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.tech_challenge_ecs_vpc.id]
  }
  tags = {
    Tier = "private"
  }
  depends_on = [aws_subnet.ecs_private_subnet_1, aws_subnet.ecs_private_subnet_2]
}

data "aws_availability_zones" "non_local" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_route_table" "selected" {
  count      = length(data.aws_subnets.private)
  subnet_id  = element(data.aws_subnets.private.ids, count.index)
  depends_on = [aws_route_table_association.private, aws_subnet.ecs_private_subnet_1, aws_subnet.ecs_private_subnet_2]
}

#### VPC ENDPOINTS

# s3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.tech_challenge_ecs_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = [for s in data.aws_route_table.selected : s.id]
  auto_accept       = true
  vpc_endpoint_type = "Gateway"
  tags = merge(
    var.tag,
    {
      Name = "sqs-vpc-endpoint"
    }
  )
  depends_on = [aws_route_table_association.private]
}

# sqs
resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.tech_challenge_ecs_vpc.id
  service_name        = "com.amazonaws.${var.region}.sqs"
  security_group_ids  = [aws_security_group.VPC_endpoint_sg.id]
  subnet_ids          = toset(data.aws_subnets.private.ids)
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"
  tags = merge(
    var.tag,
    {
      Name = "sqs-vpc-endpoint"
    }
  )
}

# SES
resource "aws_vpc_endpoint" "ses" {
  vpc_id              = aws_vpc.tech_challenge_ecs_vpc.id
  service_name        = "com.amazonaws.${var.region}.email-smtp"
  security_group_ids  = [aws_security_group.VPC_endpoint_sg.id]
  subnet_ids          = toset(data.aws_subnets.private.ids)
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"
  tags = merge(
    var.tag,
    {
      Name = "sqs-vpc-endpoint"
    }
  )
}


# API Gateway
resource "aws_vpc_endpoint" "apigateway-endpoint" {
  vpc_id              = aws_vpc.tech_challenge_ecs_vpc.id
  service_name        = "com.amazonaws.${var.region}.execute-api"
  security_group_ids  = [aws_security_group.VPC_endpoint_sg.id]
  subnet_ids          = toset(data.aws_subnets.private.ids)
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"
  tags = merge(
    var.tag,
    {
      Name = "apigateway-vpc-endpoint"
    }
  )
}

# ECR
resource "aws_vpc_endpoint" "ecr-endpoint" {
  vpc_id              = aws_vpc.tech_challenge_ecs_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  security_group_ids  = [aws_security_group.VPC_endpoint_sg.id]
  subnet_ids          = toset(data.aws_subnets.private.ids)
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"
  tags = merge(
    var.tag,
    {
      Name = "ecr-vpc-endpoint"
    }
  )
}

# cloudwatch
resource "aws_vpc_endpoint" "logs-endpoint" {
  vpc_id              = aws_vpc.tech_challenge_ecs_vpc.id
  service_name        = "com.amazonaws.${var.region}.logs"
  security_group_ids  = [aws_security_group.VPC_endpoint_sg.id]
  subnet_ids          = toset(data.aws_subnets.private.ids)
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"
  tags = merge(
    var.tag,
    {
      Name = "cloudwatch-vpc-endpoint"
    }
  )
}

# docker
resource "aws_vpc_endpoint" "docker-endpoint" {
  vpc_id              = aws_vpc.tech_challenge_ecs_vpc.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  security_group_ids  = [aws_security_group.VPC_endpoint_sg.id]
  subnet_ids          = toset(data.aws_subnets.private.ids)
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"
  tags = merge(
    var.tag,
    {
      Name = "docker-ECR-vpc-endpoint"
    }
  )
}

# ssm
resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id              = aws_vpc.tech_challenge_ecs_vpc.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  security_group_ids  = [aws_security_group.VPC_endpoint_sg.id]
  subnet_ids          = toset(data.aws_subnets.private.ids)
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"
  tags = merge(
    var.tag,
    {
      Name = "ssm-vpc-endpoint"
    }
  )
}
