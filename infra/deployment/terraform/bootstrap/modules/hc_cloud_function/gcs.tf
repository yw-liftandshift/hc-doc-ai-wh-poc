resource "google_storage_bucket" "input_pdf" {
  name                        = "${data.google_project.project.project_id}-input-pdf"
  location                    = var.region
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = var.application_kms_crypto_key
  }
}

resource "google_storage_bucket_iam_member" "input_pdf_hc_cloud_function_service_account" {
  bucket = google_storage_bucket.input_pdf.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.hc_cloud_function_service_account_email}"
}