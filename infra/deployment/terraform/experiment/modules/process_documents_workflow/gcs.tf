resource "random_uuid" "classify_documents_output_bucket" {
}

resource "google_storage_bucket_iam_member" "documents_bucket_extract_pdf_first_page_cloud_function_sa" {
  bucket = data.google_storage_bucket.documents.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.extract_pdf_first_page_cloud_function_sa_email}"
}

resource "google_storage_bucket" "process_documents_workflow" {
  name          = random_uuid.classify_documents_output_bucket.result
  location      = "northamerica-northeast1"
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "process_documents_workflow_process_documents_workflow_sa" {
  bucket = google_storage_bucket.process_documents_workflow.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.process_documents_workflow_sa_email}"
}

resource "google_storage_bucket_iam_member" "process_documents_workflow_extract_pdf_first_page_cloud_function_sa" {
  bucket = google_storage_bucket.process_documents_workflow.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.extract_pdf_first_page_cloud_function_sa_email}"
}

resource "google_storage_bucket_iam_member" "process_documents_workflow_classify_documents_cloud_function_sa" {
  bucket = google_storage_bucket.process_documents_workflow.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.classify_documents_cloud_function_sa_email}"
}

resource "google_storage_bucket_iam_member" "process_documents_workflow_postprocess_lrs_cloud_function_sa" {
  bucket = google_storage_bucket.process_documents_workflow.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.postprocess_lrs_cloud_function_sa_email}"
}

resource "google_storage_bucket_iam_member" "process_documents_workflow_postprocess_ocr_cloud_function_sa" {
  bucket = google_storage_bucket.process_documents_workflow.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.postprocess_ocr_cloud_function_sa_email}"
}