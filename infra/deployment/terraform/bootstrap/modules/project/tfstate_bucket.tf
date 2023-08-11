data "google_storage_project_service_account" "gcs_sa" {
}

resource "random_pet" "tfstate_bucket" {
  length = 4
}

resource "google_kms_crypto_key_iam_member" "gcs_sa_tfstate_bucket" {
  crypto_key_id = google_kms_crypto_key.tfstate_bucket.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_storage_project_service_account.gcs_sa.email_address}"
}

resource "google_storage_bucket" "tfstate" {
  project  = data.google_project.project.project_id
  name     = random_pet.tfstate_bucket.id
  location = var.region

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.tfstate_bucket.id
  }

  depends_on = [
    google_kms_crypto_key_iam_member.gcs_sa_tfstate_bucket
  ]
}