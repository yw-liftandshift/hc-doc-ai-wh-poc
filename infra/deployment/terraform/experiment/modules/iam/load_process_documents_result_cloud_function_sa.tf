locals {
  load_process_documents_result_cloud_function_sa_roles = [
    "roles/contentwarehouse.documentAdmin",
    "roles/logging.logWriter",
  ]
}

resource "google_service_account" "load_process_documents_result_cloud_function" {
  account_id   = "load-process-docs-result-cf"
  display_name = "Load Process Documents Result Cloud Function Service Account"
}

resource "google_project_iam_member" "load_process_documents_result_cloud_function_sa" {
  for_each = toset(local.load_process_documents_result_cloud_function_sa_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.load_process_documents_result_cloud_function.email}"
}