#create dns name
resource "aws_service_discovery_private_dns_namespace" "private_dns" {
  name        = "${local.project_name}-dns"
  description = "service discovery endpoint"
  vpc         = aws_vpc.tech_challenge_ecs_vpc.id
  tags        = var.tag
}

#attach dns name to ecsservice discovery
resource "aws_service_discovery_service" "service_discovery" {
  name = "${local.project_name}-discovery"
  tags = var.tag
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns.id
    dns_records {
      ttl  = 300
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}