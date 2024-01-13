locals {
  cloud_function_dir = "${path.module}/../../../../../../classify-documents-cloud-function"

  cloud_function_zip_path = "${path.module}/classify-documents-cloud-function.zip"
}

resource "random_uuid" "cloud_function_code_bucket" {
}

resource "google_storage_bucket" "cloud_function_code" {
  name                        = random_uuid.cloud_function_code_bucket.result
  location                    = "northamerica-northeast1"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

data "archive_file" "cloud_function_code" {
  type        = "zip"
  source_dir  = local.cloud_function_dir
  output_path = local.cloud_function_zip_path

  excludes = [
    ".env"
  ]
}

resource "google_storage_bucket_object" "cloud_function_code" {
  name   = "classify-documents-cloud-function.${data.archive_file.cloud_function_code.output_md5}.zip"
  bucket = google_storage_bucket.cloud_function_code.name
  source = local.cloud_function_zip_path
}

resource "google_cloudfunctions2_function" "classify_documents" {
  name        = "classify-documents"
  location    = "northamerica-northeast1"
  description = "Classify Documents"

  build_config {
    runtime     = "python312"
    entry_point = "main"

    docker_repository = google_artifact_registry_repository.classify_documents_cloud_function.id

    source {
      storage_source {
        bucket = google_storage_bucket.cloud_function_code.name
        object = google_storage_bucket_object.cloud_function_code.name
      }
    }
  }

  service_config {
    service_account_email = var.classify_documents_cloud_function_sa_email

    environment_variables = {
      GOOGLE_CLOUD_PROJECT_ID = data.google_project.project.project_id
      LOG_LEVEL               = "INFO"
    }

    vpc_connector                 = var.vpc_access_connector_northamerica_northeast1
    vpc_connector_egress_settings = "ALL_TRAFFIC"
  }
}
