locals {
  admins_group_roles = [
    "roles/editor",
  ]
}

resource "google_project_iam_member" "admins_group" {
  for_each = toset(local.admins_group_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "group:${var.admins_group_email}"
}

resource "google_kms_crypto_key_iam_member" "admins_group_application" {
  crypto_key_id = var.application_kms_crypto_key
  role          = "roles/cloudkms.admin"
  member        = "group:${var.admins_group_email}"
}

resource "google_kms_crypto_key_iam_member" "admins_group_doc_ai" {
  crypto_key_id = var.doc_ai_kms_crypto_key
  role          = "roles/cloudkms.admin"
  member        = "group:${var.admins_group_email}"
}

resource "google_kms_crypto_key_iam_member" "admins_group_tfvars" {
  crypto_key_id = var.tfvars_secret_kms_crypto_key
  role          = "roles/cloudkms.admin"
  member        = "group:${var.admins_group_email}"
}

resource "google_kms_crypto_key_iam_member" "admins_group_tfstate_bucket" {
  crypto_key_id = var.tfstate_bucket_kms_crypto_key
  role          = "roles/cloudkms.admin"
  member        = "group:${var.admins_group_email}"
}