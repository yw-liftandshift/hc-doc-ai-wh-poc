module "project" {
  source = "./modules/project"

  billing_account = var.billing_account
  folder_id       = var.folder_id
  project_name    = var.project_name
  project_id      = var.project_id
  region = var.region
}

# Store tfvars in Secret Manager
resource "google_secret_manager_secret" "tfvars" {
  project   = module.project.project_id
  secret_id = "terraform-tfvars"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "tfvars" {
  secret      = google_secret_manager_secret.tfvars.id
  secret_data = file("${path.module}/terraform.tfvars")
}