locals {
  cloud_functions_sa = "service-${data.google_project.project.number}@gcf-admin-robot.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "cloud_functions_sa_application" {
  crypto_key_id = var.application_kms_crypto_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${local.cloud_functions_sa}"
}