locals {
  postprocess_ocr_cloud_function_sa_roles = [
    "roles/logging.logWriter",
  ]
}

resource "google_service_account" "postprocess_ocr_cloud_function" {
  account_id   = "postprocess-ocr-cf"
  display_name = "Postprocess OCR Cloud Function Service Account"
}

resource "google_project_iam_member" "postprocess_ocr_cloud_function_sa" {
  for_each = toset(local.postprocess_ocr_cloud_function_sa_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.postprocess_ocr_cloud_function.email}"
}