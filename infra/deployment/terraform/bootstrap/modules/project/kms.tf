locals {
  doc_ai_keyring_location = var.doc_ai_location == "us" ? "us-central1" : "europe-west4" # See https://cloud.google.com/document-ai/docs/cmek#using_cmek

  rotation_period = "7776000s" # 90 days
}

resource "google_kms_key_ring" "keyring" {
  name     = "bootstrap-${var.region}-keyring"
  location = var.region

  lifecycle {
    prevent_destroy = true
  }

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

resource "google_kms_key_ring" "doc_ai_keyring" {
  name     = "bootstrap-${var.doc_ai_location}-doc-ai-keyring"
  location = local.doc_ai_keyring_location

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    google_project_service.enable_apis
  ]
}

resource "google_kms_crypto_key" "doc_ai" {
  name            = "doc-ai-key"
  key_ring        = google_kms_key_ring.doc_ai_keyring.id
  rotation_period = local.rotation_period

  lifecycle {
    prevent_destroy = true
  }
}