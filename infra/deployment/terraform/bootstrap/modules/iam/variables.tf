variable "application_key" {
  type        = string
  description = "The application KMS key ID."
}

variable "tfvars_secret_key" {
  type        = string
  description = "The terraform tfvars secret KMS key ID."
}

variable "tfstate_bucket_key" {
  type        = string
  description = "The terraform state GCS bucket KMS key ID."
}

variable "dw_ui_service_account_email" {
  type        = string
  description = "Email of the Service Account used to authenticate to the Document AI Warehouse service."
}

variable "admins_group_email" {
  type        = string
  description = "Email of the Google Cloud Group containing the system's administrators."
}

variable "users_group_email" {
  type        = string
  description = "Email of the Google Cloud Group containing the system's users."
}