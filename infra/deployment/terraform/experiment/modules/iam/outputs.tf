output "backend_sa_email" {
  value = google_service_account.backend.email
}

output "process_documents_workflow_sa_email" {
  value = google_service_account.process_documents_workflow.email
}