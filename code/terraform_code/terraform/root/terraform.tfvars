/* impersonate terraform service account */
service_account = "<terraform runner service_account>"

/* project_id */
project_id = "<project_id>"

/* Cloud Storage */
name     = "processor_training_bucket"
location = "us-central1"

/* IAM */
mode     = "additive"
projects = ["<project_id>"]
bindings = {
  "roles/bigquery.readSessionUser" = [
    "serviceAccount:<Doc Ai-service-account>",
  ]
  "roles/bigquery.user" = [
    "serviceAccount:<Doc Ai-service-account>",
  ]
  "roles/contentwarehouse.admin" = [
    "serviceAccount:<Doc Ai-service-account>",
    "user:<user_id>",
  ]
  "roles/contentwarehouse.documentAdmin" = [
    "serviceAccount:<Doc Ai-service-account>",
    "user:<user_id>",
  ]
  "roles/contentwarehouse.documentCreator" = [
    "serviceAccount:<Doc Ai-service-account>",
    "user:<user_id>",
  ]
  "roles/contentwarehouse.serviceAgent" = [
    "serviceAccount:<Doc Ai-service-account>",
  ]
  "roles/contentwarehouse.documentViewer" = [
    "serviceAccount:<Doc Ai-service-account>",
  ]
  "roles/documentai.admin" = [
    "serviceAccount:<Doc Ai-service-account>",
    "user:<user_id>"
  ]
  "roles/contentwarehouse.documentAdmin" = [
    "serviceAccount:<Doc Ai-service-account>",
  ]
  "roles/secretmanager.secretAccessor" = [
    "serviceAccount:<Doc Ai-service-account>",
  ]
  "roles/iam.serviceAccountTokenCreator" = [
    "serviceAccount:<Doc Ai-service-account>",
  ]
  "roles/storage.admin" = [
    "serviceAccount:<Doc Ai-service-account>",
    "user:<user_id>"
  ]
  "roles/storage.objectViewer" = [
    "serviceAccount:<Doc Ai-service-account>",
  ]
  "roles/aiplatform.admin" = [
    "serviceAccount:<Doc Ai-service-account>",
    "user:<user_id>",
  ]
  "roles/bigquery.admin" = [
    "user:<user_id>",
  ]
  "roles/bigquery.dataEditor" = [
    "user:<user_id>",
  ]
  "roles/errorreporting.admin" = [
    "user:<user_id>",
  ]
  "roles/logging.admin" = [
    "user:<user_id>",
  ]
  "roles/notebooks.admin" = [
    "user:<user_id>",
  ]
  "roles/notebooks.viewer" = [
    "user:<user_id>",
  ]
  "roles/iam.serviceAccountUser" = [
    "user:<user_id>",
  ]
  "roles/contentwarehouse.documentAdmin" = [
    "user:<user_id>",
  ]
  "roles/storage.admin" = [
    "user:<user_id>"
  ]
  "roles/storage.objectAdmin" = [
    "user:<user_id>",
  ]
}

/* custom role */
target_level = "project"
target_id    = "<project_id>"
role_id      = "warehouse_custom_role"
title        = "doc ai warehousecustom custom role "
description  = "custom role for doc ai warehouse"
permissions  = ["contentwarehouse.documentSchemas.create", "contentwarehouse.documentSchemas.delete", "contentwarehouse.documentSchemas.get", "contentwarehouse.documentSchemas.list", "contentwarehouse.documentSchemas.update", "contentwarehouse.documents.create", "contentwarehouse.documents.delete", "contentwarehouse.documents.get", "contentwarehouse.documents.getIamPolicy", "contentwarehouse.documents.update", "contentwarehouse.locations.initialize", "contentwarehouse.operations.get", "contentwarehouse.rawDocuments.download", "contentwarehouse.rawDocuments.upload", "contentwarehouse.synonymSets.get", "contentwarehouse.synonymSets.list", "contentwarehouse.synonymSets.update"]
members      = ["serviceAccount:<Doc Ai-service-account>"]

/* cloud function */
cloud_function_name         = "HC_cloud_fuction"
cloud_function_desc         = "HC_cloud_function for Ml code"
runtime                     = "python310"
region                      = "us-central1"
timeout                     = 540
cloud_function_code_bucket  = "cloud_function_code_bucket"
cloud_function_event_bucket = "input-pdf-bucket"
source_code_name            = "function-source.zip"
source_code_path            = "../function-source.zip"
entry_point_function        = "main"
memory                      = 8192
# environment_variables for cloud function code #
project_number               = "<project_number>"
cloud_function_code_location = "us"
input_mime_type              = "application/pdf"
schema_id                    = "<doc ai warehouse schema_id>"
sa_user                      = "user:<doc ai warehouse service account>"


/* DocAi */
docai_location        = "us"
first_processor_type  = "OCR_PROCESSOR"
second_processor_type = "CUSTOM_EXTRACTION_PROCESSOR"
first_docai_name      = "Hc-ocr_processor"
second_docai_name     = "Hc-cde_processor"


/* Api And services */
gcp_service_list = ["contentwarehouse.googleapis.com", "documentai.googleapis.com", "cloudfunctions.googleapis.com", "cloudbuild.googleapis.com"]



