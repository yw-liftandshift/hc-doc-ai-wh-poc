locals {
  log_bucket_id = "recognition_output_log"
  filter = "projects/${data.google_project.project.project_id}/logs/${local.log_bucket_id}"
}

resource "google_logging_project_sink" "recognition_result_log_sink" {
  name = "${local.log_bucket_id}_sink"

  destination = "logging.googleapis.com/projects/${data.google_project.project.project_id}/locations/global/buckets/${local.log_bucket_id}"

  filter = local.filter

  description = "The bucket contains information about recognition results"
}

resource "google_logging_project_bucket_config" "recognition_result_log_bucket" {
    project         = data.google_project.project.project_id
    location        = var.region
    retention_days  = 30
    bucket_id       = local.log_bucket_id
    enable_analytics = true
}

resource "google_logging_log_view" "recognition_result_log_view" {
  name        = "${local.log_bucket_id}_view"
  bucket      = google_logging_project_bucket_config.recognition_result_log_bucket.id
  description = "The view for recognition results"
}
