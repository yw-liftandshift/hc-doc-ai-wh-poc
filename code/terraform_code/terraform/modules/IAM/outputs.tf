output "IAM_Members" {
  description = "names of members"
  value       = module.project-iam-bindings.members
}

output "IAM_roles" {
  description = "Iam roles"
  value       = module.project-iam-bindings.roles
}
