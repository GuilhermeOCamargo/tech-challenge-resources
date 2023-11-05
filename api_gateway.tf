resource "aws_apigatewayv2_api" "tech_challenge_api_gateway" {
  name          = "${local.project_name}-api"
  protocol_type = "HTTP"
  description   = "HTTP API Gateway"
  cors_configuration {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
  tags = var.tag
}

resource "aws_apigatewayv2_integration" "tech_challenge_api_integration" {
  api_id           = aws_apigatewayv2_api.tech_challenge_api_gateway.id
  description      = "Tech Challenge load balancer integration"
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.tech_challenge_alb_listener.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.tech_challenge_vpc_link.id
}

resource "aws_apigatewayv2_vpc_link" "tech_challenge_vpc_link" {
  name               = "${local.project_name}-vpc-link"
  security_group_ids = [aws_security_group.tech_challenge_load_balancer_security_group.id]
  subnet_ids         = data.aws_subnets.private.ids

  tags = var.tag
}

resource "aws_apigatewayv2_route" "tech_challenge_route" {
  api_id    = aws_apigatewayv2_api.tech_challenge_api_gateway.id
  route_key = "ANY /tech-challenge/{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.tech_challenge_api_integration.id}"
}

resource "aws_apigatewayv2_stage" "tech_challenge_route_default_stage" {
  api_id      = aws_apigatewayv2_api.tech_challenge_api_gateway.id
  name        = "$default"
  auto_deploy = true
}