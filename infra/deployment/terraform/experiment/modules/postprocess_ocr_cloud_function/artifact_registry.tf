resource "google_artifact_registry_repository" "postprocess_ocr_cloud_function" {
  location      = "northamerica-northeast1"
  repository_id = "postprocess-ocr-cloud-function-docker-repo"
  format        = "DOCKER"
}