variable "region" {
  type        = string
  description = "The default region in which the resources will be created."
}

variable "doc_ai_location" {
  type        = string
  description = "The Doc AI processors location. Valid values are 'us' and 'eu'."
}

variable "doc_ai_kms_keyring_location" {
  type        = string
  description = "The location of the Doc AI KMS keyring."
}

variable "doc_ai_kms_crypto_key" {
  type        = string
  description = "The Doc AI KMS key ID."
}
