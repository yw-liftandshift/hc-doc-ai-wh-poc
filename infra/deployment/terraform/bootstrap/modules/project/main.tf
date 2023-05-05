locals {
  enable_apis = [
    "appengine.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "contentwarehouse.googleapis.com",
    "documentai.googleapis.com",
    "eventarc.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
    "sourcerepo.googleapis.com",
  ]
}

data "google_project" "project" {
  project_id = var.project_id
}

# Terraform state bucket
resource "random_pet" "tfstate_bucket" {
  length = 4
}

resource "google_storage_bucket" "tfstate" {
  project       = var.project_id
  name          = random_pet.tfstate_bucket.id
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

# Enable APIs
resource "google_project_service" "enable_apis" {
  for_each                   = toset(local.enable_apis)
  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = true
}