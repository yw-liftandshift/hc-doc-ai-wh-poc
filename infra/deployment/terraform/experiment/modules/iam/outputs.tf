output "backend_sa_email" {
  value = google_service_account.backend.email
}

output "extract_pdf_first_page_cloud_function_sa_email" {
  value = google_service_account.extract_pdf_first_page_cloud_function.email
}

output "classify_documents_cloud_function_sa_email" {
  value = google_service_account.classify_documents_cloud_function.email
}

output "process_documents_workflow_sa_email" {
  value = google_service_account.process_documents_workflow.email
}