data "google_project" "project" {
}

data "google_sourcerepo_repository" "sourcerepo" {
  project = data.google_project.project.project_id
  name    = var.sourcerepo_name
}

resource "google_document_ai_processor" "ocr" {
  location     = var.doc_ai_location
  display_name = "HC OCR processor"
  type         = "OCR_PROCESSOR"
}

resource "google_document_ai_processor" "cde" {
  location     = var.doc_ai_location
  display_name = "HC CDE processor"
  type         = "CUSTOM_EXTRACTION_PROCESSOR"
}

resource "google_storage_bucket" "cde_processor_training" {
  name                        = "${data.google_project.project.project_id}-cde-processor-training-bucket"
  location                    = var.region
  project                     = data.google_project.project.project_id
  uniform_bucket_level_access = true
}

resource "google_cloudbuild_trigger" "cde_processor_training" {
  name        = "cde-processor-training"
  description = "Trains the ${google_document_ai_processor.cde.display_name} using the data at ${google_storage_bucket.cde_processor_training.name}."

  source_to_build {
    uri       = data.google_sourcerepo_repository.sourcerepo.url
    ref       = "refs/heads/${var.branch_name}"
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }

  git_file_source {
    path      = "infra/deployment/terraform/bootstrap/modules/doc_ai_processors/cloudbuild.doc-ai-cde-processor-training.yaml"
    uri       = data.google_sourcerepo_repository.sourcerepo.url
    revision  = "refs/heads/${var.branch_name}"
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }

  substitutions = {
    _CDE_PROCESSOR_LOCATION             = google_document_ai_processor.cde.location
    _CDE_PROCESSOR_NAME                 = google_document_ai_processor.cde.name
    _CDE_PROCESSOR_VERSION_DISPLAY_NAME = google_document_ai_processor.cde.display_name
    _CDE_PROCESSOR_TRAINING_BUCKET_URI  = google_storage_bucket.cde_processor_training.url
  }
}
