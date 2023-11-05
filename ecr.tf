resource "aws_ecr_repository" "tech-challenge-ecr" {
  name                 = "tech-challenge-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = var.tag
}