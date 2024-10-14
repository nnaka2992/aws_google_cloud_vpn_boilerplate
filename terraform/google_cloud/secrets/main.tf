resource "google_secret_manager_secret" "main" {
  for_each = { for v in var.secret_ids : v => v }

  project   = var.project_id
  secret_id = each.value

  replication {
    auto {}
  }
}
