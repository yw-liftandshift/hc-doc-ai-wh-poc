locals {
  gcs_service_account_roles = [
    "roles/pubsub.publisher"
  ]
}

data "google_storage_project_service_account" "gcs_sa" {
}

resource "google_kms_crypto_key_iam_member" "gcs_sa_application" {
  crypto_key_id = var.application_kms_crypto_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_storage_project_service_account.gcs_sa.email_address}"
}

resource "google_kms_crypto_key_iam_member" "gcs_sa_doc_ai" {
  crypto_key_id = var.doc_ai_kms_crypto_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_storage_project_service_account.gcs_sa.email_address}"
}

resource "google_project_iam_member" "gcs_service_account" {
  for_each = toset(local.gcs_service_account_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${data.google_storage_project_service_account.gcs_sa.email_address}"
}