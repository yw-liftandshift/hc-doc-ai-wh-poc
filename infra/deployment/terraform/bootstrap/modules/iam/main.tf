locals {
  dw_ui_service_account_roles = [
    "roles/aiplatform.admin",
    "roles/bigquery.readSessionUser",
    "roles/bigquery.user",
    "roles/contentwarehouse.admin",
    "roles/contentwarehouse.documentAdmin",
    "roles/contentwarehouse.documentCreator",
    "roles/contentwarehouse.serviceAgent",
    "roles/contentwarehouse.documentViewer",
    "roles/documentai.admin",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountTokenCreator",
    "roles/storage.admin",
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

resource "random_id" "random" {
  byte_length = 4
}

resource "google_project_iam_custom_role" "warehouse_custom_role" {
  role_id     = "${random_id.random.hex}.warehouseCustomRole"
  project     = var.project_id
  title       = "Doc AI Warehouse custom role."
  description = "Doc AI Warehouse custom role."
  permissions = [
    "contentwarehouse.documentSchemas.create",
    "contentwarehouse.documentSchemas.delete",
    "contentwarehouse.documentSchemas.get",
    "contentwarehouse.documentSchemas.list",
    "contentwarehouse.documentSchemas.update",
    "contentwarehouse.documents.create",
    "contentwarehouse.documents.delete",
    "contentwarehouse.documents.get",
    "contentwarehouse.documents.getIamPolicy",
    "contentwarehouse.documents.update",
    "contentwarehouse.locations.initialize",
    "contentwarehouse.operations.get",
    "contentwarehouse.rawDocuments.download",
    "contentwarehouse.rawDocuments.upload",
    "contentwarehouse.synonymSets.get",
    "contentwarehouse.synonymSets.list",
    "contentwarehouse.synonymSets.update"
  ]
}

resource "google_project_iam_member" "dw_ui_service_account" {
  for_each = toset(local.dw_ui_service_account_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${var.dw_ui_service_account_email}"
}

resource "google_project_iam_member" "dw_ui_service_account_warehouse_custom_role" {
  project = var.project_id
  role    = google_project_iam_custom_role.warehouse_custom_role.id
  member  = "serviceAccount:${var.dw_ui_service_account_email}"
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