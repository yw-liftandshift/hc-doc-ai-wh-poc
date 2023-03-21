resource "google_document_ai_processor" "processor" {
  location     = var.docai_location
  display_name = var.doci_name
  type         = var.processor_type
  project      = var.project_id
}
