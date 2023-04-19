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

variable "ocr_processor_id" {
  type        = string
  description = "The HC OCR processor id."
}

variable "cde_processor_id" {
  type        = string
  description = "The HC CDE processor id."
}