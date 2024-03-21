resource "aws_ssm_parameter" "tech_challenge_ssm_db_url" {
  name  = "${var.ssm_prefix}/spring.datasource.url"
  type  = "String"
  value = "jdbc:mariadb://${aws_db_instance.tech_challenge_mariadb.endpoint}/${aws_db_instance.tech_challenge_mariadb.db_name}"
  tier  = "Standard"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "tech_challenge_ssm_db_username" {
  name  = "${var.ssm_prefix}/spring.datasource.username"
  type  = "String"
  value = var.db_username
  tier  = "Standard"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "tech_challenge_ssm_db_password" {
  name  = "${var.ssm_prefix}/spring.datasource.password"
  type  = "SecureString"
  value = var.db_password
  tier  = "Standard"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "tech_challenge_ssm_api_doc_url" {
  name  = "${var.ssm_prefix}/springdoc.swagger-ui.path"
  type  = "String"
  tier  = "Standard"
  value = var.api_doc_url
}

resource "aws_ssm_parameter" "tech_challenge_ssm_api_issuer" {
  name  = "${var.ssm_prefix}/spring.security.oauth2.resourceserver.jwt.issuer-uri"
  type  = "String"
  tier  = "Standard"
  value = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.tech_challenge_user_pool.id}"
}

resource "aws_ssm_parameter" "tech_challenge_ssm_ses_user" {
  name  = "${var.ssm_prefix}/spring.mail.username"
  type  = "String"
  tier  = "Standard"
  value = aws_iam_access_key.tech_challenge_ses_iam_access_key.id
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "tech_challenge_ssm_ses_password" {
  name  = "${var.ssm_prefix}/spring.mail.password"
  type  = "SecureString"
  tier  = "Standard"
  value = aws_iam_access_key.tech_challenge_ses_iam_access_key.ses_smtp_password_v4
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "tech_challenge_ssm_ses_email_from" {
  name  = "${var.ssm_prefix}/smtp.email.from"
  type  = "String"
  tier  = "Standard"
  value = var.ses_email
  lifecycle {
    ignore_changes = [value]
  }
}