resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "backend" {
  name             = "backend-${random_id.db_name_suffix.hex}"
  region           = "northamerica-northeast1"
  database_version = "POSTGRES_15"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = data.google_compute_network.vpc.id
      enable_private_path_for_google_cloud_services = true
    }
  }

  timeouts {
    create = "60m"
  }
}

resource "google_sql_database" "backend" {
  name     = "backend"
  instance = google_sql_database_instance.backend.name
}

resource "random_password" "backend_user_password" {
  keepers = {
    name = google_sql_database_instance.backend.name
  }
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
  length      = 32
  special     = false
}

resource "google_sql_user" "backend" {
  name     = "backend"
  password = random_password.backend_user_password.result
  instance = google_sql_database_instance.backend.name
}

resource "google_secret_manager_secret" "backend_user_password" {
  secret_id = "backend-user-password"

  replication {
    user_managed {
      replicas {
        location = "northamerica-northeast1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "backend_user_password" {
  secret      = google_secret_manager_secret.backend_user_password.id
  secret_data = google_sql_user.backend.password
}

resource "google_secret_manager_secret_iam_member" "backend_user_password_backend_sa" {
  secret_id = google_secret_manager_secret.backend_user_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.backend_sa_email}"
}