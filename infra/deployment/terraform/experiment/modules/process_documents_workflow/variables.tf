variable "documents_classifier_processor_id" {
  type        = string
  description = "Documents Classifier Document AI processor ID."
}

variable "documents_classifier_processor_location" {
  type        = string
  description = "Documents Classifier Document AI processor location."
}

variable "google_cloud_storage_documents_bucket" {
  type        = string
  description = "Google Cloud Storage bucket where documents are stored at."
}

variable "process_documents_workflow_sa_email" {
  type        = string
  description = "Process Documents Workflow Service Account email address."
}

variable "process_documents_workflow_pubsub_topic_id" {
  type        = string
  description = "Process Documents Workflow Trigger Pub/Sub topic ID."
}

variable "process_documents_workflow_pubsub_topic_name" {
  type        = string
  description = "Process Documents Workflow Trigger Pub/Sub topic name."
}