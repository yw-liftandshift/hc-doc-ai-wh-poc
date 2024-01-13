variable "project_id" {
  type        = string
  description = "The project ID."
}

variable "ocr_processor_id" {
  type        = string
  description = "Document AI OCR processor ID."
}

variable "ocr_processor_location" {
  type        = string
  description = "Document AI OCR processor location."
}

variable "documents_classifier_processor_id" {
  type        = string
  description = "Documents Classifier Document AI processor ID."
}

variable "documents_classifier_processor_location" {
  type        = string
  description = "Documents Classifier Document AI processor location."
}

variable "lrs_documents_cde_processor_id" {
  type        = string
  description = "LRS Documents Document AI CDE processor ID."
}

variable "lrs_documents_cde_processor_location" {
  type        = string
  description = "LRS Documents Document AI CDE processor location."
}

variable "general_documents_cde_processor_id" {
  type        = string
  description = "General Documents Document AI CDE processor ID."
}

variable "general_documents_cde_processor_location" {
  type        = string
  description = "General Documents Document AI CDE processor location."
}