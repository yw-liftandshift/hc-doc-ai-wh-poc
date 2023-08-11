output "application_kms_crypto_key" {
  value = google_kms_crypto_key.application.id
}

output "doc_ai_kms_keyring_location" {
  value = google_kms_key_ring.doc_ai_keyring.location
}

output "doc_ai_kms_crypto_key" {
  value = google_kms_crypto_key.doc_ai.id
}

output "tfvars_secret_kms_crypto_key" {
  value = google_kms_crypto_key.tfvars.id
}

output "tfstate_bucket_kms_crypto_key" {
  value = google_kms_crypto_key.tfstate_bucket.id
}

output "tfstate_bucket" {
  value = google_storage_bucket.tfstate.name
}