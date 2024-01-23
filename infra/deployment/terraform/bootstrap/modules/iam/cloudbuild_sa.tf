locals {
  cloudbuild_sa_email = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  cloudbuild_sa_roles = [
    "roles/compute.admin",
    "roles/compute.networkAdmin",
    "roles/datastore.owner",
    "roles/dlp.admin",
    "roles/documentai.admin",
    "roles/iam.serviceAccountUser",
    "roles/iap.admin",
    "roles/iap.settingsAdmin",
    "roles/iap.tunnelResourceAccessor",
    "roles/logging.admin",
    "roles/monitoring.admin",
    "roles/cloudfunctions.admin",
    "roles/secretmanager.admin",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/storage.admin",
    "roles/vpcaccess.admin"
  ]
}

resource "google_project_iam_member" "cloudbuild_sa" {
  for_each = toset(local.cloudbuild_sa_roles)
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${local.cloudbuild_sa_email}"
}