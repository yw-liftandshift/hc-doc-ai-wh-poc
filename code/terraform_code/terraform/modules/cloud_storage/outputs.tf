output "bucket_name" {
  description = "name of the bucket"
  value       = module.cloud_storage.name
}

output "bucket_names" {
  description = "name of the bucket"
  value       = module.cloud_storage.names
}
