/* impersonate service account */
service_account = "<terraform service account>"

/* Cloud Storage */
project_id = "<project_id>"
name       = "<bucket_name>"
location   = "<bucket_region>"

/* IAM */
mode     = "additive"
projects = ["<project_id>", "<project_id_2>"]
bindings = {
  "roles/bigquery.readSessionUser" = [
    "serviceAccount:<service account>",
  ]
  "roles/bigquery.user" = [
    "serviceAccount:<service account>",
  ]
  "roles/contentwarehouse.admin" = [
    "serviceAccount:<service account>",
    "user:<user_id>",
  ]
  "roles/contentwarehouse.documentAdmin" = [
    "serviceAccount:<service account>",
    "user:<user_id>",
  ]
  "roles/contentwarehouse.documentCreator" = [
    "serviceAccount:<service account>",
    "user:<user_id>",
  ]
  "roles/contentwarehouse.serviceAgent" = [
    "serviceAccount:<service account>",
  ]
  "roles/contentwarehouse.documentViewer" = [
    "serviceAccount:<service account>",
  ]
  "roles/documentai.admin" = [
    "serviceAccount:<service account>",
    "user:<user_id>"
  ]
  "roles/contentwarehouse.documentAdmin" = [
    "serviceAccount:<service account>",
  ]
  "roles/secretmanager.secretAccessor" = [
    "serviceAccount:<service account>",
  ]
  "roles/iam.serviceAccountTokenCreator" = [
    "serviceAccount:<service account>",
  ]
  "roles/storage.admin" = [
    "serviceAccount:<service account>",
    "user:<user_id>"
  ]
  "roles/storage.objectViewer" = [
    "serviceAccount:<service account>",
  ]
  "roles/aiplatform.admin" = [
    "serviceAccount:<service account>",
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
role_id      = "<role_id_name>"
title        = "<title_name>"
description  = "<description>"
permissions  = ["iam.contentwarehouse.documentSchemas.create", "iam.contentwarehouse.documentSchemas.delete", "iam.contentwarehouse.documentSchemas.get", "iam.contentwarehouse.documentSchemas.list", "iam.contentwarehouse.documentSchemas.update", "iam.contentwarehouse.documents.create", "iam.contentwarehouse.documents.delete", "iam.contentwarehouse.documents.get", "iam.contentwarehouse.documents.getIamPolicy", "iam.contentwarehouse.documents.update", "iam.contentwarehouse.locations.initialize", "iam.contentwarehouse.operations.get", "iam.contentwarehouse.rawDocuments.download", "iam.contentwarehouse.rawDocuments.upload", "iam.contentwarehouse.synonymSets.get", "iam.contentwarehouse.synonymSets.list", "iam.contentwarehouse.synonymSets.update"]
members      = ["serviceAccount:<service_account>"]

/* cloud function */
cloud_function_name = "<cloud_function_name>"
cloud_function_desc = "<description>"
runtime             = "<runtime>"
region              = "<region>"
timeout             = "<timeout in sec>"

/* DocAi */
docai_location = "us"
processor_type = "<processor type>"
doci_name      = "<name>"

/* Api And services */
gcp_service_list = ["contentwarehouse.googleapis.com", "documentai.googleapis.com", "cloudfunctions.googleapis.com", "cloudbuild.googleapis.com"]

/* service_account */
names        = ["service_account1", "service_account2"]
display_name = "<service account display name>"
descriptions = ["description1", "description2"]

/* project */
project_name    = "<project_name>"
org_id          = "<org_id>"
billing_account = "<billing_account>"
activate_apis   = ["cloudresourcemanager.googleapis.com", "serviceusage.googleapis.com"]

