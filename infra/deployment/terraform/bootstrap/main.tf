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

resource "google_cloudbuild_trigger" "deploy_on_repo_push" {
  name        = "deploy"
  description = "Build and deploy cf ${var.sourcerepo_name}/${var.branch_name} push"
  location    = "northamerica-northeast1"

  trigger_template {
    repo_name   = var.sourcerepo_name
    branch_name = var.branch_name
  }

  filename = "infra/deployment/terraform/apps/cloudbuild.yaml"

  substitutions = {
    _TFSTATE_BUCKET                     = module.project.tfstate_bucket
    _PROJECT_ID                         = var.project_id
    _REGION                             = var.region
    _DOC_AI_LOCATION                    = var.doc_ai_location
    _DW_UI_SERVICE_ACCOUNT_EMAIL        = var.dw_ui_service_account_email
    _DW_UI_SERVICE_ACCOUNT_PRIVATE_KEY  = var.dw_ui_service_account_private_key
    _SCHEMA_ID                          = var.schema_id
    _ADMINS_GROUP_EMAIL                 = var.admins_group_email
    _USERS_GROUP_EMAIL                  = var.users_group_email
    _ALERTING_EMAILS                    = join(",", var.alerting_emails)
    _SOURCEREPO_NAME                    = var.sourcerepo_name
    _BRANCH_NAME                        = var.branch_name
    _OCR_PROCESSOR_NAME                 = var.ocr_processor_name
    _CDE_LRS_TYPE_PROCESSOR_NAME        = var.cde_lrs_type_processor_name
    _CDE_GENERAL_TYPE_PROCESSOR_NAME    = var.cde_general_type_processor_name
    _CDE_CLASSIFIER_TYPE_PROCESSOR_NAME = var.cde_classifier_type_processor_name
  }
}
