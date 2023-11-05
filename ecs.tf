resource "aws_ecs_cluster" "tech_challenge_cluster" {
  name = "${local.project_name}-cluster"
  tags = var.tag
}


# module "this_nlb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "9.1.0"

#   name = "${local.project_name}-private-alb"

#   load_balancer_type = "network"

#   vpc_id          = aws_vpc.tech_challenge_ecs_vpc.id
#   subnets         = data.aws_subnets.private.ids
#   security_groups = [aws_security_group.tech_challenge_security_group.id]

#   target_groups = [{
#     target_type      = "ip"
#     backend_protocol = "HTTP"
#     backend_port     = var.container_port
#   }]

#   listeners = {
#     ex-http-https-redirect = {
#       port     = 80
#       protocol = "HTTP"
#       redirect = {
#         port        = var.container_port
#         protocol    = "HTTPS"
#         status_code = "HTTP_301"
#       }
#     }
#     ex-https = {
#       port            = var.container_port
#       protocol        = "HTTPS"
#       # certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

#       forward = {
#         target_group_key = "ex-instance"
#       }
#     }
#   }

#   tags = merge(var.tag, {Name = "${local.project_name}-private-alb"})
# }