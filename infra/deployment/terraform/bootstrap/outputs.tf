output "doc_ai_warehouse_provisioning_link" {
  value = "https://console.cloud.google.com/ai/docai-warehouse?project=${var.project_id}"
}

output "tfstate_bucket" {
  value = module.project.tfstate_bucket
}

output "tfvars_secret_id" {
  value = google_secret_manager_secret.tfvars.id
}