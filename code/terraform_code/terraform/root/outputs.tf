
output "ocr_processor_name" {
  description = "The resource name of the processor."
  value       = module.DocAi.ocr_processor_name
}

output "cde_processor_name" {
  description = "The resource name of the processor."
  value       = module.DocAi.cde_processor_name
}


output "url" {
  description = "list of bucket urls"
  value       = module.gcs.url
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
