data "google_project" "project" {
}

data "google_sourcerepo_repository" "sourcerepo" {
  name = var.sourcerepo_name
}

resource "google_document_ai_processor" "ocr" {
  location     = var.doc_ai_location
  display_name = "HC OCR processor"
  type         = "OCR_PROCESSOR"

  kms_key_name = var.doc_ai_kms_crypto_key
}

resource "google_document_ai_processor" "cde" {
  location     = var.doc_ai_location
  display_name = "HC CDE processor"
  type         = "CUSTOM_EXTRACTION_PROCESSOR"

  kms_key_name = var.doc_ai_kms_crypto_key
}

resource "google_storage_bucket" "cde_processor_training" {
  name     = "${data.google_project.project.project_id}-cde-processor-training-bucket"
  location = var.doc_ai_kms_keyring_location
  project  = data.google_project.project.project_id

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = var.doc_ai_kms_crypto_key
  }
}
