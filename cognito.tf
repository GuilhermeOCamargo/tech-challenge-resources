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
    case_sensitive = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  password_policy {
    minimum_length                   = 8
    require_numbers                  = true
    require_uppercase                = true
    require_lowercase                = true
    require_symbols                  = true
    temporary_password_validity_days = 1
  }

  schema {
    name                     = "name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
  }
  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    required                 = false
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  tags = var.tag
}

resource "aws_cognito_user_pool_domain" "tech_challenge_user_pool_domain" {
  domain       = var.user_pool_domain
  user_pool_id = aws_cognito_user_pool.tech_challenge_user_pool.id

}

resource "aws_cognito_user_pool_client" "tech_challenge_user_pool_client" {

  name                                 = "${local.project_name}-user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.tech_challenge_user_pool.id
  generate_secret                      = true
  access_token_validity                = 1 #horas
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
  callback_urls                        = ["https://example.com/"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "phone"]
  supported_identity_providers         = ["COGNITO"]

  depends_on = [aws_apigatewayv2_stage.tech_challenge_route_default_stage]
}


resource "aws_cognito_user_group" "tech_challenge_user_group" {
  name         = "grp_user"
  user_pool_id = aws_cognito_user_pool.tech_challenge_user_pool.id
  description  = "${local.project_name} user group"
}