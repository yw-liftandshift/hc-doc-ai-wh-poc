module "project-iam-bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = var.projects
  mode     = var.mode
  bindings = var.bindings
}
