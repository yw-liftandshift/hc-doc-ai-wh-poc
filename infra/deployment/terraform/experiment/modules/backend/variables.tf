variable "backend_sa_email" {
  type        = string
  description = "Backend Service Account email address."
}

variable "network_name" {
  type        = string
  description = "The VPC network name."
}

variable "vpc_access_connector_northamerica_northeast1" {
  type        = string
  description = "The northamerica-northeast1 VPC Access Connector ID."
}

variable "process_documents_workflow_pubsub_topic_name" {
  type        = string
  description = "Process Documents Workflow Trigger Pub/Sub topic name."
}