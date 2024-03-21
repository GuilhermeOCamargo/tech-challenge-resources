terraform {
  # cloud {
  #   organization = "guilherme-camargo"

  #   workspaces {
  #     name = "tech-challenge-github-action"
  #   }
  # }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }
  }

  required_version = ">= 1.2.0"
}
locals {
  project_name = "tech-challenge-hackaton"
}

provider "aws" {
  region = var.region
  profile = "default"
}