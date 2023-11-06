resource "aws_iam_role" "tech_challenge_lambda_callback_role" {
  name = "${local.project_name}-lambda-callback-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tech_challenge_attach_iam_policy_to_iam_role_cognito_callback" {
  role        = aws_iam_role.tech_challenge_lambda_callback_role.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "tech_challenge_lambda_callback_function" {
  filename      = "${path.module}/sample/lambda/lambda-hello-world.zip"
  function_name = "${local.project_name}-cognito-callback"
  role          = aws_iam_role.tech_challenge_lambda_callback_role.arn
  handler       = "cognito-callback"
  runtime       = "go1.x"
  environment {
    variables = {
	    CLIENT_ID = ""
	    CLIENT_SECRET = ""
	    API_GW_ID = ""
    }
  }
  depends_on    = [aws_iam_role_policy_attachment.tech_challenge_attach_iam_policy_to_iam_role_cognito_callback]
}

resource "aws_lambda_function_url" "tech_challenge_lambda_url_cognito_callback" {
  function_name      = aws_lambda_function.tech_challenge_lambda_callback_function.function_name
  authorization_type = "NONE"
}

resource "aws_cloudwatch_log_group" "tech_challenge_cloudwatch_cognito_callback" {
  name = "/aws/lambda/${aws_lambda_function.tech_challenge_lambda_callback_function.function_name}"

  retention_in_days = 5
}

resource "aws_apigatewayv2_api" "tech_challenge_cognito_callback_API" {
  name          = "${local.project_name}-cognito-callback-API"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "tech_challenge_stage_default" {
  api_id = aws_apigatewayv2_api.tech_challenge_cognito_callback_API.id

  name        = "default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.tech_challenge_cloudwatch_cognito_callback.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "tech_challenge_apigateway_integration_cognito_callback" {
  api_id = aws_apigatewayv2_api.tech_challenge_cognito_callback_API.id

  integration_uri    = aws_lambda_function.tech_challenge_lambda_callback_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  connection_type    = "INTERNET"  
}

resource "aws_apigatewayv2_route" "tech_challenge_apigateway_route_cognito_callback" {
  api_id = aws_apigatewayv2_api.tech_challenge_cognito_callback_API.id

  route_key = "ANY /cognito-callback"
  target    = "integrations/${aws_apigatewayv2_integration.tech_challenge_apigateway_integration_cognito_callback.id}"
}

resource "aws_cloudwatch_log_group" "cloudwatch_api_gw_callback" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.tech_challenge_cognito_callback_API.name}"

  retention_in_days = 5
}

resource "aws_lambda_permission" "permission_api_gw_callback" {
  statement_id_prefix = "lambda-"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.tech_challenge_lambda_callback_function.function_name
  principal           = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.tech_challenge_cognito_callback_API.execution_arn}/*/*"
}