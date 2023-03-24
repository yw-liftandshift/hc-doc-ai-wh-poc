resource "google_document_ai_processor" "first_processor" {
  location     = var.docai_location
  display_name = var.first_docai_name
  type         = var.first_processor_type
  project      = var.project_id
}

resource "google_document_ai_processor" "second_processor" {
  location     = var.docai_location
  display_name = var.second_docai_name
  type         = var.second_processor_type
  project      = var.project_id
}
