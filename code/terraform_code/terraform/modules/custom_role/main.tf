module "custom-roles" {
  source       = "terraform-google-modules/iam/google//modules/custom_role_iam"
  target_level = var.target_level
  target_id    = var.target_id
  role_id      = var.role_id
  title        = var.title
  description  = var.description
  permissions  = var.permissions
  members      = var.members
}
