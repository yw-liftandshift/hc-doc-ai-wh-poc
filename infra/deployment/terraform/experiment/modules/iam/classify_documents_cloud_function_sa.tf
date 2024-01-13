locals {
  classify_documents_cloud_function_sa_roles = [
    "roles/logging.logWriter",
  ]
}

resource "google_service_account" "classify_documents_cloud_function" {
  account_id   = "classify-documents-cf"
  display_name = "Clasify Documents Cloud Function Service Account"
}

resource "google_project_iam_member" "classify_documents_cloud_function_sa" {
  for_each = toset(local.classify_documents_cloud_function_sa_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.classify_documents_cloud_function.email}"
}