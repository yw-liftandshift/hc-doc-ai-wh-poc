resource "google_artifact_registry_repository" "extract_pdf_first_page_cloud_function" {
  location      = "northamerica-northeast1"
  repository_id = "extract-pdf-first-page-cloud-function-docker-repo"
  format        = "DOCKER"
}