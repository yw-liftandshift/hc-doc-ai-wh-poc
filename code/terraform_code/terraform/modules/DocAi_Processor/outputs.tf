output "ocr_processor_id" {
  description = "Iam roles"
  value       = google_document_ai_processor.first_processor.id
}

output "cde_processor_id" {
  description = "Iam roles"
  value       = google_document_ai_processor.second_processor.id
}


