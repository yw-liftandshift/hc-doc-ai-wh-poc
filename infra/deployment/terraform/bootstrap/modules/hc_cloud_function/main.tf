locals {
  hc_cloud_function_zip_path = "${path.module}/hc-cloud-function.zip"
}

data "google_project" "project" {
}

resource "google_storage_bucket" "cloud_function_code" {
  name                        = "${data.google_project.project.project_id}-hc-cloud-function-code"
  location                    = var.region
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = var.application_kms_crypto_key
  }
}

data "archive_file" "cloud_function_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../../../../../hc-cloud-function"
  output_path = local.hc_cloud_function_zip_path
}

resource "google_storage_bucket_object" "cloud_function_code" {
  name   = "hc-cloud-function.${filemd5(data.archive_file.cloud_function_code.output_path)}.zip"
  bucket = google_storage_bucket.cloud_function_code.name
  source = local.hc_cloud_function_zip_path
}

resource "google_cloudfunctions_function" "hc" {
  region                = var.region
  name                  = "hc"
  description           = "HC Cloud Function"
  runtime               = "python310"
  entry_point           = "main"
  service_account_email = var.hc_cloud_function_service_account_email
  docker_repository     = google_artifact_registry_repository.hc.id
  kms_key_name          = var.application_kms_crypto_key
  source_archive_bucket = google_storage_bucket.cloud_function_code.name
  source_archive_object = google_storage_bucket_object.cloud_function_code.name
  available_memory_mb   = 8192
  timeout               = 540

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.input_pdf.name
  }

  environment_variables = {
    project_id                            = data.google_project.project.project_id
    project_number                        = data.google_project.project.number
    location                              = var.doc_ai_location
    processor_id                          = var.ocr_processor_name
    processor_id_cde_lrs_type             = var.cde_lrs_type_processor_name
    processor_id_cde_general_type_type    = var.cde_general_type_processor_name
    processor_id_cde_classifier_type_type = var.cde_classifier_type_processor_name
    file_number_confidence_threshold      = var.file_number_confidence_threshold
    input_mime_type                       = "application/pdf"
    schema_id                             = "projects/${data.google_project.project.number}/locations/${var.doc_ai_location}/documentSchemas/${var.schema_id}"
    sa_user                               = "user:${var.dw_ui_service_account_email}"
  }
}
