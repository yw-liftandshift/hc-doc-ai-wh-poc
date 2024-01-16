resource "google_pubsub_topic_iam_member" "process_documents_workflow_pubsub_topic_backend_sa" {
  topic  = var.process_documents_workflow_pubsub_topic_name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${var.backend_sa_email}"
}


resource "google_cloud_run_v2_service" "backend" {
  name     = "backend"
  location = "northamerica-northeast1"
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.backend_sa_email

    scaling {
      max_instance_count = 1
    }

    containers {
      image = "${docker_registry_image.backend.name}@${docker_registry_image.backend.sha256_digest}"

      startup_probe {
        http_get {
          path = "/healthz"
        }
      }

      liveness_probe {
        http_get {
          path = "/healthz"
        }
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT_ID"
        value = data.google_project.project.project_id
      }
      env {
        name  = "GOOGLE_CLOUD_BIGQUERY_DOCUMENTS_TABLE"
        value = "${google_bigquery_table.documents.dataset_id}.${google_bigquery_table.documents.table_id}"
      }
      env {
        name  = "GOOGLE_CLOUD_PROCESS_DOCUMENTS_WORKFLOW_PUBSUB_TOPIC"
        value = var.process_documents_workflow_pubsub_topic_name
      }
      env {
        name  = "GOOGLE_CLOUD_STORAGE_DOCUMENTS_BUCKET"
        value = google_storage_bucket.documents.name
      }
      env {
        name  = "LOG_LEVEL"
        value = "INFO"
      }
      env {
        name  = "NODE_ENV"
        value = "production"
      }
      env {
        name  = "POSTGRES_HOST"
        value = google_sql_database_instance.backend.private_ip_address
      }
      env {
        name  = "POSTGRES_PORT"
        value = 5432
      }
      env {
        name  = "POSTGRES_DB"
        value = google_sql_database.backend.name
      }
      env {
        name  = "POSTGRES_USER"
        value = google_sql_user.backend.name
      }
      env {
        name = "POSTGRES_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.backend_user_password.secret_id
            version = "latest"
          }
        }
      }
    }

    vpc_access {
      connector = var.vpc_access_connector_northamerica_northeast1
      egress    = "ALL_TRAFFIC"
    }
  }

  depends_on = [
    google_artifact_registry_repository_iam_member.backend_repository_backend_sa,
    google_bigquery_table_iam_member.documents_backend_sa,
    google_secret_manager_secret_iam_member.backend_user_password_backend_sa,
    google_storage_bucket_iam_member.documents_backend_sa
  ]
}

resource "google_cloud_run_service_iam_member" "backend_allow_unauthenticated" {
  location = google_cloud_run_v2_service.backend.location
  service  = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}