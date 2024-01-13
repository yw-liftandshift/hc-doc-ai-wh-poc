locals {
  process_documents_workflow_sa_roles = [
    "roles/documentai.apiUser",
    "roles/logging.logWriter",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/workflows.invoker"
  ]
}

resource "google_service_account" "process_documents_workflow" {
  account_id   = "process-documents-workflow"
  display_name = "Process Documents Workflow Service Account"
}

resource "google_project_iam_member" "process_documents_workflow_sa" {
  for_each = toset(local.process_documents_workflow_sa_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.process_documents_workflow.email}"
}