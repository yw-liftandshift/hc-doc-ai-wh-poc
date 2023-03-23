variable "project_id" {
  description = "project id"
  type        = string
}

variable "service_account" {
  description = "imppersonate service account for terraform"
  type        = string
}

/* Cloud storage */
variable "location" {
  description = "location for bucket"
  type        = string
}

variable "name" {
  description = "The name of the bucket"
  type        = string
}


/* IAM */
variable "projects" {
  description = "Projects list to add the IAM policies/bindings"
  type        = list(string)
}

variable "mode" {
  description = "Mode for adding the IAM policies/bindings, additive and authoritative"
  type        = string
}

variable "bindings" {
  description = "Map of role (key) and list of members (value) to add the IAM policies/bindings"
  type        = map(list(string))
}


/* custom role */
variable "target_id" {
  description = "Variable for project or organization ID"
  type        = string
}

variable "target_level" {
  description = "String variable to denote if custom role being created is at project or organization level"
  type        = string
}

variable "title" {
  description = "Human-readable title of the Custom Role, defaults to role_id"
  type        = string
}

variable "role_id" {
  description = "ID of the Custom Role"
  type        = string
}

variable "description" {
  description = "Description of Custom role"
  type        = string
}

variable "permissions" {
  description = "IAM permissions assigned to Custom Role"
  type        = list(string)
}

variable "members" {
  description = "List of members to be added to custom role"
  type        = list(string)
}


/* cloud function */
variable "cloud_function_name" {
  description = "A user-defined name of the function. Function names must be unique globally."
  type        = string
}

variable "runtime" {
  description = "The runtime in which the function is going to run"
  type        = string
}

variable "cloud_function_desc" {
  description = "Description of the function"
  type        = string
}

variable "region" {
  description = "Region of function"
  type        = string
}

variable "timeout" {
  description = "Timeout (in seconds) for the function. Default value is 60 seconds. Cannot be more than 540 seconds"
  type        = string
}


/* DocAi */
variable "processor_type" {
  description = "The type of processor"
  type        = string
}

variable "docai_location" {
  description = "location for Docai processor"
  type        = string

}

variable "doci_name" {
  description = "name for Docai processor"
  type        = string

}


/* Api and Services */
variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)

}


/* Service account */

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

/* project */
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

