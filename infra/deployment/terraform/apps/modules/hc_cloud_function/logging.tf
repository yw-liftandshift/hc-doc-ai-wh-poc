locals {
  logs_buccket_id = "recognition_result_logs"
  filter = "projects/${data.google_project.project.project_id}/logs/${local.logs_buccket_id}"
}

resource "google_logging_project_sink" "recognition_result_logs" {
  name = "recognition_result_logs"

  destination = "logging.googleapis.com/projects/${data.google_project.project.project_id}/locations/global/buckets/${local.logs_buccket_id}"

  filter = local.filter

  description = "This log contains information about recognition results"
}
