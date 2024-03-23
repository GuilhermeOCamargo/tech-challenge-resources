variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "tag" {
  default = {
    Terraform = "true"
    Project   = "tech-challenge"
  }
  description = "AWS tag"
  type        = map(string)
}

variable "container_name" {
  default     = "tech-challenge-container"
  description = "Container Name"
}

variable "container_port" {
  default     = 8080
  description = "Container Port"
}

variable "health_check" {
  default     = "/tech-challenge/health"
  description = "Api health check"
}

variable "db_username" {
  # sensitive   = true
  default     = "user123"
  description = "Database username"
}

variable "db_password" {
  # sensitive   = true
  default     = "senha123"
  description = "Database password"
}

variable "ssm_prefix" {
  default     = "/config/tech-challenge-app_prd"
  description = "SSM key prefix"
}

variable "api_doc_url" {
  default     = "/api-doc.html"
  description = "Api doc url"
}

variable "lambda_handler" {
  default     = "cognito-callback"
  description = "Lambda handler name"
}

variable "user_pool_domain" {
  default     = "user-auth-grp36"
  description = "User pool domain name"
}

variable "ses_email" {
  description = "Email configurado no ses"
}

variable "ses_recipient_email" {
  description = "Email configurado no ses"
}