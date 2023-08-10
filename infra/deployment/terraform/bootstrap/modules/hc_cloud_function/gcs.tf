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