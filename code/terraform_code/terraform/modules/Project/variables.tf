variable "org_id" {
  description = "The organization ID."
  type        = string

}

variable "project_name" {
  description = "The name of the project to be created"
  type        = string

}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string

}

variable "activate_apis" {
  description = "The list of api's to be activated for the host project"
  type        = list(string)
}


