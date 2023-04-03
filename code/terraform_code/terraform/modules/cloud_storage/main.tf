
# resource "google_storage_bucket" "cloud_storage" {
#   project  = var.project_id
#   name     = "${var.project_id}-${var.name}"
#   location = var.location
# }


module "gcs_buckets" {
  source     = "terraform-google-modules/cloud-storage/google"
  project_id = var.project_id
  names      = var.names
  prefix     = var.project_id
  location   = var.location
}
