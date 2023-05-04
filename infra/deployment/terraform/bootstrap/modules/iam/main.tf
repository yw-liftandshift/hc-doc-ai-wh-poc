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

resource "random_id" "random" {
  byte_length = 4
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

resource "google_project_iam_custom_role" "dw_user" {
  project     = var.project_id
  role_id     = "${random_id.random.hex}.documentAIWarehouseUser"
  title       = "Document AI Warehouse User"
  description = "Contains the necessary permissions to use the Document AI Warehouse UI and trigger document processing."
  permissions = [
    "contentwarehouse.documentSchemas.get",
    "contentwarehouse.documents.create",
    "contentwarehouse.documents.delete",
    "contentwarehouse.documents.get",
    "contentwarehouse.documents.getIamPolicy",
    "contentwarehouse.documents.update",
    "contentwarehouse.locations.initialize",
    "contentwarehouse.operations.get",
    "contentwarehouse.rawDocuments.download",
    "contentwarehouse.rawDocuments.upload",
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.multipartUploads.abort",
    "storage.multipartUploads.create",
    "storage.multipartUploads.list",
    "storage.multipartUploads.listParts",
    "storage.objects.create",
    "storage.objects.list",
  ]
}