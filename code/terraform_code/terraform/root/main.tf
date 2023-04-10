
/* cloud stoarege */
module "gcs" {
  source     = "../modules/cloud_storage"
  name      = var.name
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
  source                      = "../modules/cloud_function"
  cloud_function_name         = var.cloud_function_name
  project_id                  = var.project_id
  cloud_function_desc         = var.cloud_function_desc
  runtime                     = var.runtime
  region                      = var.region
  timeout                     = var.timeout
  cloud_function_code_bucket  = var.cloud_function_code_bucket
  cloud_function_event_bucket = var.cloud_function_event_bucket
  source_code_name            = var.source_code_name
  source_code_path            = var.source_code_path
  entry_point_function        = var.entry_point_function
  memory                      = var.memory
  # environment_variables for cloud function code #
  project_number               = var.project_number
  cloud_function_code_location = var.cloud_function_code_location
  processor_id                 = module.DocAi.ocr_processor_name
  cde_processor_id             = module.DocAi.cde_processor_name
  input_mime_type              = var.input_mime_type
  schema_id                    = var.schema_id
  sa_user                      = var.sa_user
  depends_on                   = [module.Services, module.DocAi]
}

/* DocAi */
module "DocAi" {
  source                = "../modules/DocAi_Processor"
  first_docai_name      = var.first_docai_name
  second_docai_name     = var.second_docai_name
  docai_location        = var.docai_location
  first_processor_type  = var.first_processor_type
  second_processor_type = var.second_processor_type
  project_id            = var.project_id
  depends_on            = [module.Services]
}

/* Apis and services */
module "Services" {
  source           = "../modules/Services"
  project_id       = var.project_id
  gcp_service_list = var.gcp_service_list

}


