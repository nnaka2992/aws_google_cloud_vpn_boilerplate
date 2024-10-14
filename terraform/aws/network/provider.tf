terraform {
  required_version = "~> 1.9.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.62.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project   = "${var.project_name}"
      ManagedBy = "Terraform"
    }
  }
}
