resource "google_artifact_registry_repository" "load_process_documents_result_cloud_function" {
  location      = "northamerica-northeast1"
  repository_id = "load-process-documents-result-cloud-function-docker-repo"
  format        = "DOCKER"
}