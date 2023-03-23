module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  project_id    = var.project_id
  prefix        = ""
  names         = var.names
  generate_keys = true
  display_name  = var.display_name
  descriptions  = var.descriptions
  project_roles = ["${var.project_id}=>roles/viewer", "${var.project_id}=>roles/storage.objectViewer", ]
}
