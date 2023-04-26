locals {
  dw_ui_service_account_roles = [
    "roles/aiplatform.admin",
    "roles/bigquery.admin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.readSessionUser",
    "roles/bigquery.user",
    "roles/contentwarehouse.admin",
    "roles/contentwarehouse.documentAdmin",
    "roles/contentwarehouse.documentCreator",
    "roles/contentwarehouse.serviceAgent",
    "roles/contentwarehouse.documentViewer",
    "roles/documentai.admin",
    "roles/errorreporting.admin",
    "roles/logging.admin",
    "roles/notebooks.admin",
    "roles/notebooks.viewer",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/storage.admin",
    "roles/storage.objectAdmin",
    "roles/storage.objectViewer",
  ]

  cloudbuild_service_account_email = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  cloudbuild_service_account_roles = [
    "roles/documentai.admin"
  ]

  gcs_service_account_email = "service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"

  gcs_service_account_roles = [
    "roles/pubsub.publisher"
  ]
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "dw_ui_service_account" {
  for_each = toset(local.dw_ui_service_account_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${var.dw_ui_service_account_email}"
}

resource "google_project_iam_member" "cloudbuild_service_account" {
  for_each = toset(local.cloudbuild_service_account_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${local.cloudbuild_service_account_email}"
}

resource "google_project_iam_member" "gcs_service_account" {
  for_each = toset(local.gcs_service_account_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${local.gcs_service_account_email}"
}