variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
}

variable "project_id" {
  description = "project id "
  type        = string
}
