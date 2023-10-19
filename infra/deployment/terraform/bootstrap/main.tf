provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

module "project" {
  source = "./modules/project"

  region          = var.region
  doc_ai_location = var.doc_ai_location
}

module "iam" {
  source = "./modules/iam"

  application_kms_crypto_key    = module.project.application_kms_crypto_key
  doc_ai_kms_crypto_key         = module.project.doc_ai_kms_crypto_key
  tfvars_secret_kms_crypto_key  = module.project.tfvars_secret_kms_crypto_key
  tfstate_bucket_kms_crypto_key = module.project.tfstate_bucket_kms_crypto_key
  dw_ui_service_account_email   = var.dw_ui_service_account_email
  admins_group_email            = var.admins_group_email
  users_group_email             = var.users_group_email
}

module "monitoring" {
  source = "./modules/monitoring"

  alerting_emails = var.alerting_emails
}

module "doc_ai_processors" {
  source = "./modules/doc_ai_processors"

  region                      = var.region
  doc_ai_location             = var.doc_ai_location
  doc_ai_kms_keyring_location = module.project.doc_ai_kms_keyring_location
  doc_ai_kms_crypto_key       = module.project.doc_ai_kms_crypto_key

  depends_on = [
    module.iam
  ]
}

module "hc_cloud_function" {
  source = "./modules/hc_cloud_function"

  region                                  = var.region
  application_kms_crypto_key              = module.project.application_kms_crypto_key
  hc_cloud_function_service_account_email = module.iam.hc_cloud_function_service_account_email
  dw_ui_service_account_email             = var.dw_ui_service_account_email
  schema_id                               = var.schema_id
  doc_ai_location                         = var.doc_ai_location
  ocr_processor_name                      = module.doc_ai_processors.ocr_processor_name
  cde_lrs_type_processor_name             = module.doc_ai_processors.cde_lrs_type_processor_name
  monitoring_notification_channel_ids     = module.monitoring.monitoring_notification_alerting_emails.*.id
}

# Store tfvars in Secret Manager
resource "google_secret_manager_secret" "tfvars" {
  secret_id = "terraform-tfvars"

  replication {
    user_managed {
      replicas {
        location = var.region

        customer_managed_encryption {
          kms_key_name = module.project.tfvars_secret_kms_crypto_key
        }
      }
    }
  }
}

resource "google_secret_manager_secret_version" "tfvars" {
  secret      = google_secret_manager_secret.tfvars.id
  secret_data = file("${path.module}/terraform.tfvars")
}