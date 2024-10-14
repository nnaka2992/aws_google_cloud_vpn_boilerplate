terraform {
  required_version = "~> 1.9.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.62.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~>5.40.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project   = "${var.project_name}"
      ManagedBy = "Terraform"
    }
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
  default_labels = {
    project   = replace(var.project_name, "_", "-")
    manage_by = "terraform"
  }
}
