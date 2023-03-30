
resource "google_storage_bucket" "cloud_storage" {
  project  = var.project_id
  name     = "${var.project_id}-${var.name}"
  location = var.location
}
