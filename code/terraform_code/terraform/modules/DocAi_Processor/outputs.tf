output "ocr_processor_id" {
  description = "an identifier for the resource with format projects/{{project}}/locations/{{location}}/processors/{{name}}"
  value       = google_document_ai_processor.first_processor.id
}

output "ocr_processor_name" {
  description = "The resource name of the processor."
  value       = google_document_ai_processor.first_processor.name
}

output "cde_processor_id" {
  description = "an identifier for the resource with format projects/{{project}}/locations/{{location}}/processors/{{name}}"
  value       = google_document_ai_processor.second_processor.id
}

output "cde_processor_name" {
  description = "an identifier for the resource with format projects/{{project}}/locations/{{location}}/processors/{{name}}"
  value       = google_document_ai_processor.second_processor.name
}


