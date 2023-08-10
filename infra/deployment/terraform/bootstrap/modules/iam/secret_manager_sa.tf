locals {
  secret_manager_service_agent_identity = "service-${data.google_project.project.number}@gcp-sa-secretmanager.iam.gserviceaccount.com"
}

# See https://cloud.google.com/secret-manager/docs/cmek#service-identity
resource "null_resource" "secret_manager_service_agent_identity" {
  provisioner "local-exec" {
    command = "gcloud beta services identity create --service \"secretmanager.googleapis.com\" --project ${data.google_project.project.project_id}"
  }
}

resource "google_kms_crypto_key_iam_member" "secret_manager_service_agent_identity_terraform_tvars" {
  crypto_key_id = var.tfvars_secret_kms_crypto_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${local.secret_manager_service_agent_identity}"

  depends_on = [
    null_resource.secret_manager_service_agent_identity
  ]
}