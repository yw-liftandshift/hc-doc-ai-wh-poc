locals {
  postprocess_lrs_cloud_function_sa_roles = [
    "roles/logging.logWriter",
  ]
}

resource "google_service_account" "postprocess_lrs_cloud_function" {
  account_id   = "postprocess-lrs-cf"
  display_name = "Postprocess LRS Cloud Function Service Account"
}

resource "google_project_iam_member" "postprocess_lrs_cloud_function_sa" {
  for_each = toset(local.postprocess_lrs_cloud_function_sa_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.postprocess_lrs_cloud_function.email}"
}