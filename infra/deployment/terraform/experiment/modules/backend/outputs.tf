output "cloud_run_service_name" {
  value = google_cloud_run_v2_service.backend.name
}

output "cloud_run_service_url" {
  value = google_cloud_run_v2_service.backend.uri
}