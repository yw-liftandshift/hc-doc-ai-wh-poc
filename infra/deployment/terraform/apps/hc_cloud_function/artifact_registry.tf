resource "google_artifact_registry_repository" "hc" {
  location      = var.region
  repository_id = "hc-cloud-function"
  format        = "DOCKER"
  kms_key_name  = var.application_kms_crypto_key
}
