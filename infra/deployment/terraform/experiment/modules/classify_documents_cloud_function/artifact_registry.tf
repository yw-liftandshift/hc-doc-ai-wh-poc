resource "google_artifact_registry_repository" "classify_documents_cloud_function" {
  location      = "northamerica-northeast1"
  repository_id = "classify-documents-cloud-function-docker-repo"
  format        = "DOCKER"
}