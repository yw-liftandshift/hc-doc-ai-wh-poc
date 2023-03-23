module "host-project" {
  source                         = "terraform-google-modules/project-factory/google"
  name                           = var.project_name
  random_project_id              = true
  org_id                         = var.org_id
  billing_account                = var.billing_account
  activate_apis                  = var.activate_apis
  default_service_account        = "keep"
  enable_shared_vpc_host_project = true
}



