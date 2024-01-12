data "google_project" "project" {
}

data "google_compute_network" "vpc" {
  name = var.network_name
}