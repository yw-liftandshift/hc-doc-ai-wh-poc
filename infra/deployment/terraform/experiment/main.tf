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

module "backend" {
  source = "./modules/backend"

  backend_sa_email                             = module.iam.backend_sa_email
  network_name                                 = module.network.network_name
  vpc_access_connector_northamerica_northeast1 = module.network.vpc_access_connector_northamerica_northeast1_id

  depends_on = [
    module.enable_apis
  ]
}