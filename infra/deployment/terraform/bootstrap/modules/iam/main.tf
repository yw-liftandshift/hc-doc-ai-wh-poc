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