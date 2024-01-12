resource "random_uuid" "documents_bucket" {
}

resource "google_storage_bucket" "documents" {
  name     = random_uuid.documents_bucket.result
  location = "northamerica-northeast1"

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "documents_backend_sa" {
  bucket = google_storage_bucket.documents.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.backend_sa_email}"
}