output "project_number" {
  value = module.project.project_number
}

output "doc_ai_warehouse_provisioning_link" {
  value = "https://console.cloud.google.com/ai/docai-warehouse?project=${var.project_id}"
}

output "cde_processor_id" {
  value = module.doc_ai_processors.cde_processor_id
}

output "cde_processor_name" {
  value = module.doc_ai_processors.cde_processor_name
}

output "cde_processor_display_name" {
  value = module.doc_ai_processors.cde_processor_display_name
}

output "cde_processor_training_bucket_name" {
  value = module.doc_ai_processors.cde_processor_training_bucket_name
}

output "cde_processor_training_cloudbuild_trigger" {
  value = module.doc_ai_processors.cde_processor_training_cloudbuild_trigger
}

output "tfstate_bucket" {
  value = module.project.tfstate_bucket
}

output "tfvars_secret_id" {
  value = google_secret_manager_secret.tfvars.id
}