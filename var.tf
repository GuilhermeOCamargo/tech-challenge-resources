variable "ami_id" {
    default     = "ami-0df435f331839b2d6"
    description = "AMI ID"
}

variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "tag" {
  default = "tech-challenge"
  description = "AWS tag"
}