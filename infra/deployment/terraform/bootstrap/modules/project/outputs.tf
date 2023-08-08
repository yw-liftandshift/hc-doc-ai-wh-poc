output "application_key" {
  value = google_kms_crypto_key.application.id
}

output "tfvars_secret_key" {
  value = google_kms_crypto_key.tfvars.id
}

output "tfstate_bucket_key" {
  value = google_kms_crypto_key.tfstate_bucket.id
}

output "tfstate_bucket" {
  value = google_storage_bucket.tfstate.name
}