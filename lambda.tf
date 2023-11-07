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
  role       = aws_iam_role.tech_challenge_lambda_callback_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "tech_challenge_lambda_callback_function" {
  filename      = "${path.module}/sample/lambda/lambda-auth-callback.zip"
  function_name = "${local.project_name}-${var.lambda_handler}"
  role          = aws_iam_role.tech_challenge_lambda_callback_role.arn
  handler       = var.lambda_handler
  runtime       = "go1.x"
  environment {
    variables = {
      CLIENT_ID     = aws_cognito_user_pool_client.tech_challenge_user_pool_client.id
      CLIENT_SECRET = aws_cognito_user_pool_client.tech_challenge_user_pool_client.client_secret
      URL_REDIRECT  = "${aws_apigatewayv2_stage.tech_challenge_route_default_stage.invoke_url}${var.lambda_handler}"
      URL_GET_TOKEN = "https://${var.user_pool_domain}.auth.${var.region}.amazoncognito.com/oauth2/token"
      URL_SIGNIN    = "https://${var.user_pool_domain}.auth.${var.region}.amazoncognito.com/oauth2/authorize"

    }
  }
  depends_on = [aws_iam_role_policy_attachment.tech_challenge_attach_iam_policy_to_iam_role_cognito_callback, aws_cognito_user_pool_client.tech_challenge_user_pool_client]
}

resource "aws_lambda_function_url" "tech_challenge_lambda_url_cognito_callback" {
  function_name      = aws_lambda_function.tech_challenge_lambda_callback_function.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "permission_api_gw_callback" {
  statement_id_prefix = "lambda-"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.tech_challenge_lambda_callback_function.function_name
  principal           = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.tech_challenge_api_gateway.execution_arn}/*/*"
}