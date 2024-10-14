locals {
  project_name = replace(var.project_name, "_", "-")
}
resource "google_compute_network" "main" {
  name                    = "${local.project_name}-network"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  mtu                     = 1460
}
