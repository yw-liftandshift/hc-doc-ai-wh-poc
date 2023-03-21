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
