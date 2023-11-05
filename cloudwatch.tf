resource "aws_cloudwatch_log_group" "log_group_create" {
  name              = "/ecs/${local.project_name}-task"
  retention_in_days = 1
}