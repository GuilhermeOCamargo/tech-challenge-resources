resource "aws_ecs_cluster" "tech_challenge_cluster" {
  name = "${local.project_name}-cluster"
  tags = var.tag
}