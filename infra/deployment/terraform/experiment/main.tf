provider "google" {
  project               = var.project_id
  region                = "northamerica-northeast1"
  user_project_override = true
}

provider "google-beta" {
  project               = var.project_id
  region                = "northamerica-northeast1"
  user_project_override = true
}

provider "docker" {
  registry_auth {
    address  = "northamerica-northeast1-docker.pkg.dev"
    username = "oauth2accesstoken"
    password = data.google_client_config.default.access_token
  }
}

data "google_client_config" "default" {
}

module "enable_apis" {
  source = "./modules/enable_apis"
}

module "iam" {
  source = "./modules/iam"

  depends_on = [
    module.enable_apis
  ]
}

module "network" {
  source = "./modules/network"

  depends_on = [
    module.enable_apis
  ]
}

module "pubsub" {
  source = "./modules/pubsub"

  depends_on = [
    module.enable_apis
  ]
}


module "backend" {
  source = "./modules/backend"

  backend_sa_email                             = module.iam.backend_sa_email
  network_name                                 = module.network.network_name
  vpc_access_connector_northamerica_northeast1 = module.network.vpc_access_connector_northamerica_northeast1_id
  process_documents_workflow_pubsub_topic_name = module.pubsub.process_documents_workflow_topic_name
}

module "extract_pdf_first_page_cloud_function" {
  source = "./modules/extract_pdf_first_page_cloud_function"

  extract_pdf_first_page_cloud_function_sa_email = module.iam.extract_pdf_first_page_cloud_function_sa_email
  vpc_access_connector_northamerica_northeast1   = module.network.vpc_access_connector_northamerica_northeast1_id
}

module "classify_documents_cloud_function" {
  source = "./modules/classify_documents_cloud_function"

  classify_documents_cloud_function_sa_email   = module.iam.classify_documents_cloud_function_sa_email
  vpc_access_connector_northamerica_northeast1 = module.network.vpc_access_connector_northamerica_northeast1_id
}

module "postprocess_lrs_cloud_function" {
  source = "./modules/postprocess_lrs_cloud_function"

  postprocess_lrs_cloud_function_sa_email      = module.iam.postprocess_lrs_cloud_function_sa_email
  vpc_access_connector_northamerica_northeast1 = module.network.vpc_access_connector_northamerica_northeast1_id
}

module "postprocess_ocr_cloud_function" {
  source = "./modules/postprocess_ocr_cloud_function"

  postprocess_ocr_cloud_function_sa_email      = module.iam.postprocess_ocr_cloud_function_sa_email
  vpc_access_connector_northamerica_northeast1 = module.network.vpc_access_connector_northamerica_northeast1_id
}

module "load_process_documents_result_cloud_function" {
  source = "./modules/load_process_documents_result_cloud_function"

  load_process_documents_result_cloud_function_sa_email = module.iam.load_process_documents_result_cloud_function_sa_email
  vpc_access_connector_northamerica_northeast1          = module.network.vpc_access_connector_northamerica_northeast1_id
}

module "process_documents_workflow" {
  source = "./modules/process_documents_workflow"

  ocr_processor_id                                 = var.ocr_processor_id
  ocr_processor_location                           = var.ocr_processor_location
  documents_classifier_processor_id                = var.documents_classifier_processor_id
  documents_classifier_processor_location          = var.documents_classifier_processor_location
  lrs_documents_cde_processor_id                   = var.lrs_documents_cde_processor_id
  lrs_documents_cde_processor_location             = var.lrs_documents_cde_processor_location
  general_documents_cde_processor_id               = var.general_documents_cde_processor_id
  general_documents_cde_processor_location         = var.general_documents_cde_processor_location
  extract_pdf_first_page_cloud_function_sa_email   = module.iam.extract_pdf_first_page_cloud_function_sa_email
  extract_pdf_first_page_cloud_function_url        = module.extract_pdf_first_page_cloud_function.url
  classify_documents_cloud_function_sa_email       = module.iam.classify_documents_cloud_function_sa_email
  classify_documents_cloud_function_url            = module.classify_documents_cloud_function.url
  postprocess_lrs_cloud_function_sa_email          = module.iam.postprocess_lrs_cloud_function_sa_email
  postprocess_lrs_cloud_function_url               = module.postprocess_lrs_cloud_function.url
  postprocess_ocr_cloud_function_sa_email          = module.iam.postprocess_ocr_cloud_function_sa_email
  postprocess_ocr_cloud_function_url               = module.postprocess_ocr_cloud_function.url
  load_process_documents_result_cloud_function_url = module.load_process_documents_result_cloud_function.url
  google_cloud_storage_documents_bucket            = module.backend.google_cloud_storage_documents_bucket
  process_documents_workflow_sa_email              = module.iam.process_documents_workflow_sa_email
  process_documents_workflow_pubsub_topic_id       = module.pubsub.process_documents_workflow_topic_id
  process_documents_workflow_pubsub_topic_name     = module.pubsub.process_documents_workflow_topic_name
}