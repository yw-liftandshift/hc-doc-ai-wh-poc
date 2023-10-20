output "doc_ai_warehouse_provisioning_link" {
  value = "https://console.cloud.google.com/ai/docai-warehouse?project=${var.project_id}"
}

output "cde_lrs_type_processor_name" {
  value = module.doc_ai_processors.cde_lrs_type_processor_name
}

output "cde_general_type_processor_name" {
  value = module.doc_ai_processors.cde_general_type_processor_name
}

output "cde_classifier_type_processor_name" {
  value = module.doc_ai_processors.cde_classifier_type_processor_name
}

output "cde_lrs_type_processor_display_name" {
  value = module.doc_ai_processors.cde_lrs_type_processor_display_name
}

output "cde_general_type_processor_display_name" {
  value = module.doc_ai_processors.cde_general_type_processor_display_name
}

output "cde_classifier_type_processor_display_name" {
  value = module.doc_ai_processors.cde_classifier_type_processor_display_name
}

output "input_pdf_bucket" {
  value = module.hc_cloud_function.input_pdf_bucket
}

output "tfstate_bucket" {
  value = module.project.tfstate_bucket
}

output "tfvars_secret_id" {
  value = google_secret_manager_secret.tfvars.id
}