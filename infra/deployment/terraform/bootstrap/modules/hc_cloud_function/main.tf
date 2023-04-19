locals {
  hc_cloud_function_zip_path = "${path.module}/hc-cloud-function.zip"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_storage_bucket" "cloud_function_code" {
  project                     = var.project_id
  name                        = "${var.project_id}-hc-cloud-function-code"
  location                    = var.region
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "input_pdf" {
  project                     = var.project_id
  name                        = "${var.project_id}-input-pdf"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "cloud_function_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../../../../../hc-cloud-function"
  output_path = local.hc_cloud_function_zip_path
}

resource "google_storage_bucket_object" "cloud_function_code" {
  name   = "hc-cloud-function.${filemd5(local.hc_cloud_function_zip_path)}.zip"
  bucket = google_storage_bucket.cloud_function_code.name
  source = local.hc_cloud_function_zip_path

  depends_on = [
    data.archive_file.cloud_function_code
  ]
}

resource "google_cloudfunctions_function" "hc" {
  project               = var.project_id
  region                = var.region
  name                  = "hc"
  description           = "HC Cloud Function"
  runtime               = "python310"
  available_memory_mb   = 8192
  entry_point           = "main"
  source_archive_bucket = google_storage_bucket.cloud_function_code.name
  source_archive_object = google_storage_bucket_object.cloud_function_code.name
  timeout               = 540

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.input_pdf.name
  }

  environment_variables = {
    project_id       = var.project_id
    project_number   = data.google_project.project.number
    location         = var.doc_ai_location
    processor_id     = var.ocr_processor_name
    processor_id_cde = var.cde_processor_name
    input_mime_type  = "application/pdf"
    schema_id        = "projects/${data.google_project.project.number}/locations/${var.doc_ai_location}/documentSchemas/${var.schema_id}"
    sa_user          = "user:${var.dw_ui_service_account_email}"
  }
}