output "ocr_processor_id" {
  value = google_document_ai_processor.ocr.id
}

output "cde_processor_id" {
  value = google_document_ai_processor.cde.id
}

output "cde_processor_location" {
  value = google_document_ai_processor.cde.location
}

output "cde_processor_display_name" {
  value = google_document_ai_processor.cde.display_name
}

output "cde_processor_training_bucket_name" {
  value = google_storage_bucket.cde_processor_training.name
}

output "cde_processor_training_bucket_url" {
  value = google_storage_bucket.cde_processor_training.url
}