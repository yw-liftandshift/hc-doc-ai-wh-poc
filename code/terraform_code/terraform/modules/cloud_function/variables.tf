
variable "project_id" {
  description = "project id for cloud function"
  type        = string
}

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

variable "cloud_function_code_bucket" {
  description = "bucket contain ml source code"
  type        = string
}

variable "cloud_function_event_bucket" {
  description = "event bucket trigger cloud function"
  type        = string

}

variable "source_code_name" {
  description = "source code name"
  type        = string
}

variable "source_code_path" {
  description = "source code path"
  type        = string
}

variable "entry_point_function" {
  description = "entry point function name"
  type        = string
}

variable "memory" {
  description = "function memory"
  type        = string
}

# environment_variables for cloud function code #
variable "project_number" {
  description = "project no for cloud function"
  type        = string
}

variable "cloud_function_code_location" {
  description = "location for cloud function code"
  type        = string
}

variable "processor_id" {
  description = "ocr processor id"
  type        = string
}

variable "cde_processor_id" {
  description = "cde processor id"
  type        = string
}
variable "input_mime_type" {
  description = "input_mime_type for ml code"
  type        = string
}

variable "schema_id" {
  description = "schema_id for ml code"
  type        = string
}

variable "sa_user" {
  description = "service account user for ml code"
  type        = string
}


















