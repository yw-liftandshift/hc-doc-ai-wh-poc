module "project" {
  source = "./modules/project"

  billing_account = var.billing_account
  folder_id       = var.folder_id
  project_name    = var.project_name
  project_id      = var.project_id
  region          = var.region
}

module "iam" {
  source = "./modules/iam"

  project_id                  = module.project.project_id
  dw_ui_service_account_email = var.dw_ui_service_account_email
}

module "doc_ai_processors" {
  source = "./modules/doc_ai_processors"

  project_id = module.project.project_id
  region     = var.region
}

module "hc_cloud_function" {
  source = "./modules/hc_cloud_function"

  project_id                  = module.project.project_id
  region                      = var.region
  dw_ui_service_account_email = var.dw_ui_service_account_email
  ocr_processor_id            = module.doc_ai_processors.ocr_processor_id
  cde_processor_id            = module.doc_ai_processors.cde_processor_id
}

# Store tfvars in Secret Manager
resource "google_secret_manager_secret" "tfvars" {
  project   = module.project.project_id
  secret_id = "terraform-tfvars"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "tfvars" {
  secret      = google_secret_manager_secret.tfvars.id
  secret_data = file("${path.module}/terraform.tfvars")
}