resource "aws_lb" "tech_challenge_alb" {
  name               = "${local.project_name}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tech_challenge_load_balancer_security_group.id]
  subnets            = toset(data.aws_subnets.private.ids)

  enable_deletion_protection = false

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.id
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = var.tag
}

resource "aws_lb_listener" "tech_challenge_alb_listener" {
  load_balancer_arn = aws_lb.tech_challenge_alb.arn
  port              = 80
  protocol          = "HTTP"
  #   ssl_policy        = "ELBSecurityPolicy-2016-08"
  #   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tech_challenge_target_group.arn
  }
}

resource "aws_lb_target_group" "tech_challenge_target_group" {
  name        = "${local.project_name}-tg"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.tech_challenge_ecs_vpc.id
  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 6
    interval            = 10
    matcher             = "200"
    path                = var.health_check
    protocol            = "HTTP"
  }
}
