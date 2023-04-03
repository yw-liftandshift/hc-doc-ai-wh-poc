variable "project_id" {
  description = "project id for bucket"
  type        = string
}

variable "location" {
  description = "location for bucket"
  type        = string
}

variable "names" {
  description = "The name of the bucket"
  type        = list(string)
}


