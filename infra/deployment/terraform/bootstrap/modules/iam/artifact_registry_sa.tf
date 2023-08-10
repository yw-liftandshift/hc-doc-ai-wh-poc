locals {
  artifact_registry_sa = "service-${data.google_project.project.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com"
}

# See https://cloud.google.com/artifact-registry/docs/ar-service-account
resource "null_resource" "artifact_registry_sa" {
  provisioner "local-exec" {
    command = "gcloud beta services identity create --service \"artifactregistry.googleapis.com\" --project ${data.google_project.project.project_id}"
  }
}

resource "google_kms_crypto_key_iam_member" "artifact_registry_sa_application" {
  crypto_key_id = var.application_kms_crypto_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${local.artifact_registry_sa}"

  depends_on = [
    null_resource.artifact_registry_sa
  ]
}