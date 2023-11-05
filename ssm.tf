resource "aws_ssm_parameter" "tech_challenge_ssm_db_url" {
  name  = "${var.ssm_prefix}/spring.datasource.url"
  type  = "String"
  value = "jdbc:mariadb://${aws_db_instance.tech_challenge_mariadb.endpoint}/${aws_db_instance.tech_challenge_mariadb.db_name}"
  tier = "Standard"
  lifecycle {
    ignore_changes = [ value ]
  }
}

resource "aws_ssm_parameter" "tech_challenge_ssm_db_username" {
  name  = "${var.ssm_prefix}/spring.datasource.username"
  type  = "String"
  value = var.db_username
  tier = "Standard"
  lifecycle {
    ignore_changes = [ value ]
  }
}

resource "aws_ssm_parameter" "tech_challenge_ssm_db_password" {
  name  = "${var.ssm_prefix}/spring.datasource.password"
  type  = "SecureString"
  value = var.db_password
  tier = "Standard"
  lifecycle {
    ignore_changes = [ value ]
  }
}

resource "aws_ssm_parameter" "tech_challenge_ssm_api_doc_url" {
  name  = "${var.ssm_prefix}/springdoc.swagger-ui.path"
  type  = "String"
  tier = "Standard"
  value = var.api_doc_url
}