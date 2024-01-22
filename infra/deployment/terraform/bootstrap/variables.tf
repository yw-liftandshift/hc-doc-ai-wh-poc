variable "project_id" {
  type        = string
  description = "The project ID."
}

variable "region" {
  type        = string
  description = "The default region in which the resources will be created."
}

variable "doc_ai_location" {
  type        = string
  description = "The Doc AI processors location. Valid values are 'us' and 'eu'."
}

variable "dw_ui_service_account_email" {
  type        = string
  description = "Email of the Service Account used to authenticate to the Document AI Warehouse service."
}

variable "dw_ui_service_account_private_key" {
  type        = string
  description = "Private key of the Service Account used to authenticate to the Document AI Warehouse service."
  sensitive   = true
}

variable "schema_id" {
  type        = string
  description = "The ID of the Document schema to be used in the HC Cloud Function."
}

variable "admins_group_email" {
  type        = string
  description = "Email of the Google Cloud Group containing the system's administrators."
}

variable "users_group_email" {
  type        = string
  description = "Email of the Google Cloud Group containing the system's users."
}

variable "alerting_emails" {
  type        = list(string)
  description = "Email addresses that will receive monitoring alerts."
}

variable "sourcerepo_name" {
  type        = string
  description = "The Cloud Source Repository name."
}

variable "branch_name" {
  type        = string
  description = "The Cloud Source repository branch name."
}

variable "ocr_processor_name" {
  type = string
}

variable "cde_lrs_type_processor_name" {
  type = string
}

variable "cde_general_type_processor_name" {
  type = string
}

variable "cde_classifier_type_processor_name" {
  type = string
}