variable "region" {
  type        = string
  description = "The default region in which the resources will be created."
}

variable "application_kms_crypto_key" {
  type        = string
  description = "The application KMS key ID."
}

variable "hc_cloud_function_service_account_email" {
  type        = string
  description = "Email of the Service Account used to run the HC Cloud Function."
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
  description = "The HC OCR processor name."
}

variable "cde_lrs_type_processor_name" {
  type        = string
  description = "The HC CDE lrs type processor name."
}

variable "cde_general_type_processor_name" {
  type        = string
  description = "The HC CDE general type processor name."
}

variable "cde_classifier_type_processor_name" {
  type        = string
  description = "The HC CDE classifier type processor name."
}

variable "monitoring_notification_channel_ids" {
  type        = list(string)
  description = "Monitoring Notification Channel ids."
}

variable "file_number_confidence_threshold" {
  type        = number
  description = "File number confidence threshold."
  default     = 0.7
}
