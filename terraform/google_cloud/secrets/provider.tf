terraform {
  required_version = "~> 1.9.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>5.40.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  default_labels = {
    project    = "${var.project_name}"
    managed_by = "terraform"
  }
}