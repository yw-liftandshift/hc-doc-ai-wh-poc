locals {
  doc_ai_sa = "service-${data.google_project.project.number}@gcp-sa-prod-dai-core.iam.gserviceaccount.com"
}

# See https://cloud.google.com/artifact-registry/docs/ar-service-account
resource "null_resource" "doc_ai_sa" {
  provisioner "local-exec" {
    command = "gcloud beta services identity create --service \"documentai.googleapis.com\" --project ${data.google_project.project.project_id}"
  }
}

resource "google_kms_crypto_key_iam_member" "doc_ai_sa_doc_ai" {
  crypto_key_id = var.doc_ai_kms_crypto_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${local.doc_ai_sa}"

  depends_on = [
    null_resource.doc_ai_sa
  ]
}