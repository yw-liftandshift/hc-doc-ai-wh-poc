
module "gcs_buckets" {
  source     = "terraform-google-modules/cloud-storage/google"
  project_id = var.project_id
  names      = var.names
  prefix     = var.project_id
  location   = var.location
}
