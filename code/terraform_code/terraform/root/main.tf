module "project" {
  source          = "../modules/project"
  project_name    = var.project_name
  org_id          = var.org_id
  billing_account = var.billing_account
  activate_apis   = var.activate_apis

}

/* cloud stoarege */
module "gcs" {
  source = "../modules/cloud_storage"
  name   = var.name
  #project_id=module.project.project_id       # use this if project create from terraform and remove project_id from root/variables.tf and root/terraform.tfvars
  project_id = var.project_id #remove this if you create project from terraform 
  location   = var.location
  depends_on = [module.project]
}

/* IAM */
module "IAM" {
  source = "../modules/IAM"
  #projects=[module.project.project_id]        # use this if project create from terraform and remove project_id from root/variables.tf and root/terraform.tfvars
  projects   = var.projects #remove this if you create project from terraform 
  mode       = var.mode
  bindings   = var.bindings
  depends_on = [module.project]
}

/* custom role */
module "custom-role" {
  source       = "../modules/custom_role"
  target_level = var.target_level
  #project_id=module.project.project_id       # use this if project create from terraform and remove project_id from root/variables.tf and root/terraform.tfvars
  target_id   = var.project_id #remove this if you create project from terraform 
  role_id     = var.role_id
  title       = var.title
  description = var.description
  permissions = var.permissions
  members     = var.members
  depends_on  = [module.project]
}

/* cloud function */
module "cloud_function" {
  source              = "../modules/cloud_function"
  cloud_function_name = var.cloud_function_name
  #project_id=module.project.project_id       # use this if project create from terraform and remove project_id from root/variables.tf and root/terraform.tfvars
  project_id          = var.project_id #remove this if you create project from terraform 
  cloud_function_desc = var.cloud_function_desc
  runtime             = var.runtime
  region              = var.region
  timeout             = var.timeout
  depends_on          = [module.Services, module.project]
}

/* DocAi */
module "DocAi" {
  source         = "../modules/DocAi_Processor"
  doci_name      = var.doci_name
  docai_location = var.docai_location
  processor_type = var.processor_type
  #project_id=module.project.project_id               # use this if project create from terraform and remove project_id from root/variables.tf and root/terraform.tfvars
  project_id = var.project_id #remove this if you create project from terraform 
  depends_on = [module.Services, module.project]
}

/* Apis and services */
module "Services" {
  source = "../modules/Services"
  #project_id=module.project.project_id       # use this if project create from terraform and remove project_id from root/variables.tf and root/terraform.tfvars
  project_id       = var.project_id #remove this if you create project from terraform 
  gcp_service_list = var.gcp_service_list
  depends_on       = [module.project]
}

/* service account */
module "Service_account" {
  source = "../modules/Service_Accounts"
  #project_id=module.project.project_id       # use this if project create from terraform and remove project_id from root/variables.tf and root/terraform.tfvars
  project_id   = var.project_id #remove this if you create project from terraform 
  names        = var.names
  descriptions = var.descriptions
  display_name = var.display_name
  depends_on   = [module.project]
}

