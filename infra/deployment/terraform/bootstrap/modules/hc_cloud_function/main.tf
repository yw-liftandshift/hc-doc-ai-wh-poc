locals {
  hc_cloud_function_zip      = "hc-cloud-function.zip"
  hc_cloud_function_zip_path = "${path.module}/${local.hc_cloud_function_zip}"
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
  name   = local.hc_cloud_function_zip
  bucket = google_storage_bucket.cloud_function_code.name
  source = local.hc_cloud_function_zip_path

  depends_on = [
    data.archive_file.cloud_function_code
  ]
}

resource "google_cloudfunctions2_function" "hc" {
  project     = var.project_id
  name        = "hc"
  location    = var.region
  description = "HC Cloud Function"

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.storage.object.v1.finalized"
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.input_pdf.name
    }
  }

  build_config {
    runtime     = "python310"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_function_code.name
        object = google_storage_bucket_object.cloud_function_code.name
      }
    }
  }

  service_config {
    max_instance_count = 100
    available_memory   = "8192M"
    timeout_seconds    = 540

    environment_variables = {
      project_id       = var.project_id
      project_number   = data.google_project.project.number
      location         = var.region
      processor_id     = var.ocr_processor_id
      processor_id_cde = var.cde_processor_id
      input_mime_type  = "application/pdf"
      sa_user          = "serviceAccount:${var.dw_ui_service_account_email}"
    }
  }
}