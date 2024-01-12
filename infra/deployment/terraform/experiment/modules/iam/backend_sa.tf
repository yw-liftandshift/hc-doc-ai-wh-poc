locals {
  backend_sa_roles = [
  ]
}

resource "google_service_account" "backend" {
  account_id   = "backend"
  display_name = "Backend Service Account"
}

resource "google_project_iam_member" "backend_sa" {
  for_each = toset(local.backend_sa_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.backend.email}"
}