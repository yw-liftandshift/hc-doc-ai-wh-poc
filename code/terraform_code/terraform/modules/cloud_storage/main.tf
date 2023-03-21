
resource "google_storage_bucket" "cloud_function_code" {
  project  = var.project_id
  name     = "${var.project_id}-<bucket_name>"
  location = var.location
}
