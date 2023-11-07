resource "aws_db_instance" "tech_challenge_mariadb" {
  allocated_storage      = 10
  db_name                = "TechChallengeAppDb"
  identifier             = "${local.project_name}-db"
  engine                 = "mariadb"
  engine_version         = "10.11.5"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  port                   = 3306
  parameter_group_name   = "default.mariadb10.11"
  skip_final_snapshot    = true
  apply_immediately      = true
  db_subnet_group_name   = aws_db_subnet_group.tech_challenge_subnet_group.name
  vpc_security_group_ids = [aws_security_group.tech_challenge_db_security_group.id]
}