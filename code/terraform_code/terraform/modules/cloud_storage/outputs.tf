output "url" {
  description = "list of bucket urls"
  value       = google_storage_bucket.gcs.url
}
