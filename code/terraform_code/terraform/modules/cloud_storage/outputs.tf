output "bucket_names" {
  description = "name of the bucket"
  value       = module.gcs_buckets.names
}

output "urls" {
  description = "list of bucket urls"
  value       = module.gcs_buckets.urls_list
}
