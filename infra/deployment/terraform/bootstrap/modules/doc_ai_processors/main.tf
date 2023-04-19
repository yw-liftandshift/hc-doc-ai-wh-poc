resource "google_document_ai_processor" "ocr" {
  project      = var.project_id
  location     = var.region
  display_name = "HC OCR processor"
  type         = "OCR_PROCESSOR"
}

resource "google_document_ai_processor" "cde" {
  project      = var.project_id
  location     = var.region
  display_name = "HC CDE processor"
  type         = "CUSTOM_EXTRACTION_PROCESSOR"
}

resource "google_storage_bucket" "cde_processor_training" {
  name                        = "${var.project_id}-cde-processor-training-bucket"
  location                    = var.region
  project                     = var.project_id
  force_destroy               = true
  uniform_bucket_level_access = true
}