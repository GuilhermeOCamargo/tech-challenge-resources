resource "aws_security_group" "tech_challenge_security_group" {
  name        = "${local.project_name}-sg"
  description = "${local.project_name} security group"
  vpc_id      = aws_vpc.tech_challenge_ecs_vpc.id
  tags        = var.tag
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.tech_challenge_load_balancer_security_group.id]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tech_challenge_load_balancer_security_group" {
  name        = "${local.project_name}-load-balancer-sg"
  description = "${local.project_name} security group"
  vpc_id      = aws_vpc.tech_challenge_ecs_vpc.id
  tags        = var.tag
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "VPC_endpoint_sg" {
  name        = "${local.project_name}-VPC_endpoin-sg"
  description = "${local.project_name} security group"
  vpc_id      = aws_vpc.tech_challenge_ecs_vpc.id
  tags        = var.tag
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "tech_challenge_db_security_group" {
  name        = "${local.project_name}-db-sg"
  description = "${local.project_name} database security group"
  vpc_id      = aws_vpc.tech_challenge_ecs_vpc.id
  tags        = var.tag
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.tech_challenge_security_group.id]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}