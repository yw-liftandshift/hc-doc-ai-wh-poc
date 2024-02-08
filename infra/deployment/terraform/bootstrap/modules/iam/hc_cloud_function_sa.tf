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
    "documentai.processors.get",
    "documentai.processors.list",
    "documentai.processorVersions.get",
    "documentai.processorVersions.list",
    "resourcemanager.projects.get",
    "logging.logEntries.create"
  ]
}

resource "google_project_iam_member" "hc_cloud_function_service_account" {
  project = data.google_project.project.project_id
  role    = google_project_iam_custom_role.hc_cloud_function.name
  member  = "serviceAccount:${google_service_account.hc_cloud_function.email}"
}