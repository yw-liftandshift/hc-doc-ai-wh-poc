locals {
  alerting_emails_list = split(",", var.alerting_emails)
}

module "monitoring" {
  source = "./modules/monitoring"

  alerting_emails = local.alerting_emails_list
}

module "hc_cloud_function" {
  source = "./modules/hc_cloud_function"

  region                                  = var.region
  application_kms_crypto_key              = var.application_kms_crypto_key
  hc_cloud_function_service_account_email = var.hc_cloud_function_service_account_email
  dw_ui_service_account_email             = var.dw_ui_service_account_email
  schema_id                               = var.schema_id
  doc_ai_location                         = var.doc_ai_location
  ocr_processor_name                      = var.ocr_processor_name
  cde_lrs_type_processor_name             = var.cde_lrs_type_processor_name
  cde_general_type_processor_name         = var.cde_general_type_processor_name
  cde_classifier_type_processor_name      = var.cde_classifier_type_processor_name
  monitoring_notification_channel_ids     = module.monitoring.monitoring_notification_alerting_emails.*.id
}
