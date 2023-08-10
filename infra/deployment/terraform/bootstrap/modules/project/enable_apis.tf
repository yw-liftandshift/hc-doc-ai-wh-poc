locals {
  enable_apis = [
    "appengine.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
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

resource "google_project_service" "enable_apis" {
  for_each                   = toset(local.enable_apis)
  project                    = data.google_project.project.project_id
  service                    = each.value
  disable_dependent_services = true
}