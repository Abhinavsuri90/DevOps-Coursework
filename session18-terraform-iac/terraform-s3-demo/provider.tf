terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.68"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Every resource gets these tags automatically.
  default_tags {
    tags = {
      Project   = "DevOps-Coursework"
      Session   = "18-terraform-iac"
      Owner     = var.owner
      ManagedBy = "Terraform"
    }
  }
}
