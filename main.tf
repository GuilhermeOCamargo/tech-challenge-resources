terraform {
   cloud {
    organization = "guilherme-camargo"

    workspaces {
      name = "tech-challenge-github-action"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.21.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "aws_ecr_repository" "tech-challenge-api" {
  name                 = "tech-challenge-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}