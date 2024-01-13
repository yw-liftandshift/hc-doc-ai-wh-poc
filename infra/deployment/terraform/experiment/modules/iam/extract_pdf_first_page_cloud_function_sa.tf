locals {
  extract_pdf_first_page_cloud_function_sa_roles = [
    "roles/logging.logWriter",
  ]
}

resource "google_service_account" "extract_pdf_first_page_cloud_function" {
  account_id   = "extract-pdf-first-page-cf"
  display_name = "Extract PDF First Page Cloud Function Service Account"
}

resource "google_project_iam_member" "extract_pdf_first_page_cloud_function_sa" {
  for_each = toset(local.extract_pdf_first_page_cloud_function_sa_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.extract_pdf_first_page_cloud_function.email}"
}