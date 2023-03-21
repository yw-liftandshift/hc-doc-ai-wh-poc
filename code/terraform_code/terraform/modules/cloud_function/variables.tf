
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

