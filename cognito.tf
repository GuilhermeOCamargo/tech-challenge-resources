resource "aws_cognito_user_pool" "tech_challenge_user_pool" {

  name                     = "${local.project_name}-user-pool"
  alias_attributes         = ["preferred_username"]
  auto_verified_attributes = ["email"] 

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }
  
  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"] 
  }

  username_configuration {
    case_sensitive = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }  

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    required                 = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_domain" "tech_challenge_user_pool_domain" {
  domain       = "tech-challenge-grp36"
  user_pool_id = aws_cognito_user_pool.tech_challenge_user_pool.id
}

resource "aws_cognito_user_pool_client" "userPoolClientRestaurantApp" {

  name                                 = "${local.project_name}"
  user_pool_id                         = aws_cognito_user_pool.tech_challenge_user_pool.id
  generate_secret                      = true
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
  callback_urls                        = ["${aws_apigatewayv2_stage.tech_challenge_stage_default.invoke_url}/cognito-callback"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "phone"]
  supported_identity_providers         = ["COGNITO"]

  depends_on    = [aws_lambda_function.tech_challenge_lambda_callback_function,aws_apigatewayv2_stage.tech_challenge_stage_default]
}
