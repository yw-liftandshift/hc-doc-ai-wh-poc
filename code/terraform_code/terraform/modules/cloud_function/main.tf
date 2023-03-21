resource "google_storage_bucket" "cloud_function_code" {
  project                     = var.project_id
  name                        = "${var.project_id}-<bucket_name>" #contain cloud function source code
  location                    = "<region>"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "event_bucket" {
  project  = var.project_id
  name     = "${var.project_id}-cf-event-bucket" # this bucket trigger cloud function
  location = "<region>"
}

resource "google_storage_bucket_object" "object" {
  name   = "<object_name.zip>"
  bucket = google_storage_bucket.cloud_function_code.name
  source = "<object path>" # Add path to the zipped function source code

}

resource "google_cloudfunctions_function" "function" {
  name                  = var.cloud_function_name
  description           = var.cloud_function_desc
  runtime               = var.runtime
  available_memory_mb   = "<available_memory>"
  entry_point           = "<entry point function>"
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
