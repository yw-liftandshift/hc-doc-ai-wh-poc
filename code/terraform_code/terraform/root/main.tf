/* cloud stoarege */
module "gcs" {
  source     = "../modules/cloud_storage"
  name       = var.name
  project_id = var.project_id
  location   = var.location
}

/* IAM */
module "IAM" {
  source   = "../modules/IAM"
  projects = var.projects
  mode     = var.mode
  bindings = var.bindings
}

/* custom role */
module "custom-role" {
  source       = "../modules/custom_role"
  target_level = var.target_level
  target_id    = var.project_id
  role_id      = var.role_id
  title        = var.title
  description  = var.description
  permissions  = var.permissions
  members      = var.members
}

/* cloud function */
module "cloud_function" {
  source              = "../modules/cloud_function"
  cloud_function_name = var.cloud_function_name
  project_id          = var.project_id
  cloud_function_desc = var.cloud_function_desc
  runtime             = var.runtime
  region              = var.region
  timeout             = var.timeout
  depends_on          = [module.Services]
}

/* DocAi */
module "DocAi" {
  source         = "../modules/DocAi_Processor"
  doci_name      = var.doci_name
  docai_location = var.docai_location
  processor_type = var.processor_type
  project_id     = var.project_id
  depends_on     = [module.Services]
}

/* Apis and services */
module "Services" {
  source           = "../modules/Services"
  project_id       = var.project_id
  gcp_service_list = var.gcp_service_list
}
