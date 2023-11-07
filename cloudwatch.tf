resource "aws_cloudwatch_log_group" "log_group_create" {
  name              = "/ecs/${local.project_name}-task"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "tech_challenge_cloudwatch_cognito_callback" {
  name = "/lambda/${aws_lambda_function.tech_challenge_lambda_callback_function.function_name}"

  retention_in_days = 5
}

resource "aws_cloudwatch_log_group" "tech_challenge_api_gateway_logs" {
  name = "/api_gw/${aws_apigatewayv2_api.tech_challenge_api_gateway.name}"

  retention_in_days = 5
}