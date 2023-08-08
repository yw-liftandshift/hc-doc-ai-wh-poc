variable "region" {
  type        = string
  description = "The default region in which the resources will be created."
}

variable "doc_ai_location" {
  type        = string
  description = "The Doc AI processors location. Valid values are 'us' and 'eu'."
}

variable "sourcerepo_name" {
  type        = string
  description = "The Cloud Source Repository name."
}

variable "branch_name" {
  type        = string
  description = "The Cloud Source repository branch name."
}