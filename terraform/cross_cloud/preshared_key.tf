locals {
  preshared_key = data.google_secret_manager_secret_version.main.secret_data
}

data "google_secret_manager_secret_version" "main" {
  project = var.google_project_id
  secret  = var.preshared_key_secret_id
  version = "latest"
}
