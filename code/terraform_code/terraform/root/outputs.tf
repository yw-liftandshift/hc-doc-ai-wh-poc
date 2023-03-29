output "ocr_processor_id" {
  description = "Iam roles"
  value       = module.DocAi.ocr_processor_id
}

output "cde_processor_id" {
  description = "Iam roles"
  value       = module.DocAi.cde_processor_id
}


output "bucket_name" {
  description = "name of the bucket"
  value       = module.gcs.bucket_name
}


output "custom_role_id" {
  description = "id of custom role"
  value       = module.custom-role.custom_role_id
}

output "service-account-emails" {
  description = "ID of the project"
  value       = module.Service_account.service-account-emails
}


output "IAM_Members" {
  description = "names of members"
  value       = module.IAM.IAM_Members
}

output "IAM_roles" {
  description = "Iam roles"
  value       = module.IAM.IAM_roles
}
