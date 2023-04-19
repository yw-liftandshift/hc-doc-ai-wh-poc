variable "project_id" {
  type        = string
  description = "The project ID."
}

variable "region" {
  type        = string
  description = "The default region in which the resources will be created."
}

variable "dw_ui_service_account_email" {
  type        = string
  description = "Email of the Service Account used to authenticate to the Document AI Warehouse service."
}

variable "schema_id" {
  type        = string
  description = "The ID of the Document schema to be used in the HC Cloud Function."
}

variable "doc_ai_location" {
  type        = string
  description = "The Doc AI processors location. Valid values are 'us' and 'eu'."
}

variable "ocr_processor_name" {
  type        = string
  description = "The HC OCR processor id."
}

variable "cde_processor_name" {
  type        = string
  description = "The HC CDE processor name."
}