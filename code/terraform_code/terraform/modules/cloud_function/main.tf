# contain cloud function ml source code
resource "google_storage_bucket" "cloud_function_code" {
  project                     = var.project_id
  name                        = "${var.project_id}-${var.cloud_function_code_bucket}"
  location                    = var.region
  uniform_bucket_level_access = true
}

# this bucket trigger cloud function
resource "google_storage_bucket" "event_bucket" {
  project  = var.project_id
  name     = "${var.project_id}-${var.cloud_function_event_bucket}" # this bucket trigger cloud function
  location = var.region
}

# this will upload the ml source code to cloud_function_code
resource "google_storage_bucket_object" "object" {
  name   = var.source_code_name
  bucket = google_storage_bucket.cloud_function_code.name
  source = var.source_code_path # path to the ml source code in a zip format

}

resource "google_cloudfunctions_function" "function" {
  name                  = var.cloud_function_name
  description           = var.cloud_function_desc
  runtime               = var.runtime
  available_memory_mb   = var.memory
  entry_point           = var.entry_point_function # entry function of ml source code
  source_archive_bucket = google_storage_bucket.cloud_function_code.name
  source_archive_object = google_storage_bucket_object.object.name
  region                = var.region
  timeout               = var.timeout
  project               = var.project_id
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.event_bucket.name
  }
  depends_on = [google_storage_bucket.cloud_function_code, google_storage_bucket_object.object, google_storage_bucket.event_bucket]
}
