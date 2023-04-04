output "ocr_processor_id" {
  description = "an identifier for the resource with format projects/{{project}}/locations/{{location}}/processors/{{name}}"
  value       = module.DocAi.ocr_processor_id
}

output "cde_processor_id" {
  description = "an identifier for the resource with format projects/{{project}}/locations/{{location}}/processors/{{name}}"
  value       = module.DocAi.cde_processor_id
}

output "ocr_processor_name" {
  description = "The resource name of the processor."
  value       = module.DocAi.ocr_processor_name
}

output "cde_processor_name" {
  description = "The resource name of the processor."
  value       = module.DocAi.cde_processor_name
}

output "bucket_name" {
  description = "name of the bucket"
  value       = module.gcs.bucket_names
}

output "urls" {
  description = "list of bucket urls"
  value       = module.gcs.urls
}


output "custom_role_id" {
  description = "id of custom role"
  value       = module.custom-role.custom_role_id
}


output "IAM_Members" {
  description = "names of members"
  value       = module.IAM.IAM_Members
}

output "IAM_roles" {
  description = "Iam roles"
  value       = module.IAM.IAM_roles
}
