locals {
  logs_buccket_id = "recognition_result_logs"
  filter = "projects/${data.google_project.project.project_id}/logs/${local.logs_buccket_id}"
}

resource "google_logging_project_sink" "recognition_result_logs_bucket" {
  name = "${local.logs_buccket_id}_sink"

  destination = "logging.googleapis.com/projects/${data.google_project.project.project_id}/locations/global/buckets/${local.logs_buccket_id}"

  filter = local.filter

  description = "The bucket contains information about recognition results"
}

resource "google_logging_project_bucket_config" "recognition_result_logs_bucket" {
    project         = data.google_project.project.project_id
    location        = var.region
    retention_days  = 30
    bucket_id       = local.logs_buccket_id
    enable_analytics = true
}

resource "google_logging_log_view" "logging_log_view" {
  name        = "${local.logs_buccket_id}_view"
  bucket      = google_logging_project_bucket_config.recognition_result_logs_bucket.id
  description = "The view for recognition results"
}
