output "cloud_run_service_name" {
  value = google_cloud_run_v2_service.backend.name
}

output "cloud_run_service_url" {
  value = google_cloud_run_v2_service.backend.uri
}

output "google_cloud_storage_documents_bucket" {
  value = google_storage_bucket.documents.name
}
