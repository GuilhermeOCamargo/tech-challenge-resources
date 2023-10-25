terraform {
  #  cloud {
  #   organization = "guilherme-camargo"

  #   workspaces {
  #     name = "tech-challenge-github-action"
  #   }
  # }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.21.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
  profile = "default"
}