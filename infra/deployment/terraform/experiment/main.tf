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

module "process_documents_workflow" {
  source = "./modules/process_documents_workflow"

  documents_classifier_processor_id            = var.documents_classifier_processor_id
  documents_classifier_processor_location      = var.documents_classifier_processor_location
  google_cloud_storage_documents_bucket        = module.backend.google_cloud_storage_documents_bucket
  process_documents_workflow_sa_email          = module.iam.process_documents_workflow_sa_email
  process_documents_workflow_pubsub_topic_id   = module.pubsub.process_documents_workflow_topic_id
  process_documents_workflow_pubsub_topic_name = module.pubsub.process_documents_workflow_topic_name
}