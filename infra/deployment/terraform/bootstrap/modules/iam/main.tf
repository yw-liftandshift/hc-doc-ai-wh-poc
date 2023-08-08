locals {
  cloudbuild_service_account_email = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  cloudbuild_service_account_roles = [
    "roles/documentai.admin"
  ]

  gcs_service_account_email = "service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"

  gcs_service_account_roles = [
    "roles/pubsub.publisher"
  ]

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

  admins_group_email_roles = [
    "roles/editor",
  ]
}

data "google_project" "project" {
}

resource "random_id" "random" {
  byte_length = 4
}

# Cloud Build Service Account
resource "google_project_iam_member" "cloudbuild_service_account" {
  for_each = toset(local.cloudbuild_service_account_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${local.cloudbuild_service_account_email}"
}

# GCS Service Account
resource "google_project_iam_member" "gcs_service_account" {
  for_each = toset(local.gcs_service_account_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${local.gcs_service_account_email}"
}

# Secret Manager service agent identity
# See https://cloud.google.com/secret-manager/docs/cmek#service-identity
resource "null_resource" "secret_manager_service_agent_identity" {
  provisioner "local-exec" {
    command = "gcloud beta services identity create --service \"secretmanager.googleapis.com\" --project ${data.google_project.project.project_id}"
  }
}

# HC Cloud Function Service Account
resource "google_service_account" "hc_cloud_function" {
  account_id   = "hc-cloud-function"
  display_name = "HC Cloud Function Service Account"
}

resource "google_project_iam_custom_role" "hc_cloud_function" {
  role_id     = "${random_id.random.hex}.hcCloudFunction"
  title       = "HC Cloud Function Service Account custom role"
  description = "Contains the permissions necessary to run the HC Cloud Function"
  permissions = [
    "contentwarehouse.documentSchemas.get",
    "contentwarehouse.documentSchemas.list",
    "contentwarehouse.documents.create",
    "documentai.humanReviewConfigs.review",
    "documentai.operations.getLegacy",
    "documentai.processorVersions.processBatch",
    "documentai.processorVersions.processOnline",
    "documentai.processors.processBatch",
    "documentai.processors.processOnline",
    "resourcemanager.projects.get",
    "resourcemanager.projects.list"
  ]
}

resource "google_project_iam_member" "hc_cloud_function_service_account" {
  project = data.google_project.project.project_id
  role    = google_project_iam_custom_role.hc_cloud_function.name
  member  = "serviceAccount:${google_service_account.hc_cloud_function.email}"
}

# DW UI Service Account
resource "google_project_iam_member" "dw_ui_service_account" {
  for_each = toset(local.dw_ui_service_account_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${var.dw_ui_service_account_email}"
}

# Admins Group
resource "google_project_iam_member" "admins_group" {
  for_each = toset(local.admins_group_email_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "group:${var.admins_group_email}"
}

resource "google_kms_crypto_key_iam_member" "admins_group_application" {
  crypto_key_id = var.application_key
  role          = "roles/cloudkms.admin"
  member        = "group:${var.admins_group_email}"
}

resource "google_kms_crypto_key_iam_member" "admins_group_tfvars" {
  crypto_key_id = var.tfvars_secret_key
  role          = "roles/cloudkms.admin"
  member        = "group:${var.admins_group_email}"
}

resource "google_kms_crypto_key_iam_member" "admins_group_tfstate_bucket" {
  crypto_key_id = var.tfstate_bucket_key
  role          = "roles/cloudkms.admin"
  member        = "group:${var.admins_group_email}"
}

# Users Group
resource "google_project_iam_custom_role" "dw_user" {
  project     = data.google_project.project.project_id
  role_id     = "${random_id.random.hex}.documentAIWarehouseUser"
  title       = "Document AI Warehouse User"
  description = "Contains the necessary permissions to use the Document AI Warehouse UI and trigger document processing."
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
    "contentwarehouse.documents.setIamPolicy",
    "contentwarehouse.documents.update",
    "contentwarehouse.locations.initialize",
    "contentwarehouse.operations.get",
    "contentwarehouse.rawDocuments.download",
    "contentwarehouse.rawDocuments.upload",
    "contentwarehouse.ruleSets.create",
    "contentwarehouse.ruleSets.delete",
    "contentwarehouse.ruleSets.get",
    "contentwarehouse.ruleSets.list",
    "contentwarehouse.ruleSets.update",
    "contentwarehouse.synonymSets.create",
    "contentwarehouse.synonymSets.delete",
    "contentwarehouse.synonymSets.get",
    "contentwarehouse.synonymSets.list",
    "contentwarehouse.synonymSets.update",
    "firebase.projects.get",
    "orgpolicy.policy.get",
    "recommender.iamPolicyInsights.get",
    "recommender.iamPolicyInsights.list",
    "recommender.iamPolicyInsights.update",
    "recommender.iamPolicyRecommendations.get",
    "recommender.iamPolicyRecommendations.list",
    "recommender.iamPolicyRecommendations.update",
    "resourcemanager.projects.get",
    "storage.buckets.create",
    "storage.buckets.createTagBinding",
    "storage.buckets.delete",
    "storage.buckets.deleteTagBinding",
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.getObjectInsights",
    "storage.buckets.list",
    "storage.buckets.listEffectiveTags",
    "storage.buckets.listTagBindings",
    "storage.buckets.setIamPolicy",
    "storage.buckets.update",
    "storage.multipartUploads.abort",
    "storage.multipartUploads.create",
    "storage.multipartUploads.list",
    "storage.multipartUploads.listParts",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.getIamPolicy",
    "storage.objects.list",
    "storage.objects.setIamPolicy",
    "storage.objects.update",
  ]
}

resource "google_project_iam_member" "dw_user_users_group" {
  project = data.google_project.project.project_id
  role    = google_project_iam_custom_role.dw_user.name
  member  = "group:${var.users_group_email}"
}

# Enable audit logs
resource "google_project_iam_audit_config" "project" {
  project = data.google_project.project.project_id
  service = "allServices"
  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}