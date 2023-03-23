variable "project_id" {
  description = "Project id where service account will be created"
  type        = string
}

variable "names" {
  description = "Names of the service accounts to create"
  type        = list(string)
}

variable "display_name" {
  description = "Display names of the created service accounts"
  type        = string
}

variable "descriptions" {
  description = "Display names of the created service accounts"
  type        = list(string)
}
