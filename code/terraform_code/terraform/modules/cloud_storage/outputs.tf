output "bucket_name" {
  description = "name of the bucket"
  value       = google_storage_bucket.cloud_storage.name
}

# output "bucket_names" {
#   description = "name of the bucket"
#   value       = google_storage_bucket.cloud_storage.names
# }
