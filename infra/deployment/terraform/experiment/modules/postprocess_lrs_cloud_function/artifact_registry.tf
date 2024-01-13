resource "google_artifact_registry_repository" "postprocess_lrs_cloud_function" {
  location      = "northamerica-northeast1"
  repository_id = "postprocess-lrs-cloud-function-docker-repo"
  format        = "DOCKER"
}