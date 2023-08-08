locals {
  enable_apis = [
    "appengine.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "contentwarehouse.googleapis.com",
    "documentai.googleapis.com",
    "eventarc.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
    "sourcerepo.googleapis.com",
  ]

  rotation_period = "7776000s" # 90 days
}

data "google_project" "project" {
}

data "google_storage_project_service_account" "gcs_sa" {
}

# Enable APIs
resource "google_project_service" "enable_apis" {
  for_each                   = toset(local.enable_apis)
  project                    = data.google_project.project.project_id
  service                    = each.value
  disable_dependent_services = true
}

# KMS
resource "google_kms_key_ring" "keyring" {
  name     = "keyring"
  location = var.region

  depends_on = [
    google_project_service.enable_apis
  ]
}

resource "google_kms_crypto_key" "application" {
  name            = "application-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = local.rotation_period

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "tfvars" {
  name            = "terraform-tfvars-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = local.rotation_period

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "tfstate_bucket" {
  name            = "tfstate-bucket-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = local.rotation_period

  lifecycle {
    prevent_destroy = true
  }
}

# Terraform state bucket
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