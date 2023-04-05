
resource "google_storage_bucket" "gcs" {
  name                        = "${var.project_id}_${var.name}"
  location                    = var.location
  project                     = var.project_id
  force_destroy               = true
  uniform_bucket_level_access = true
}
