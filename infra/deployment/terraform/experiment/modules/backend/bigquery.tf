resource "google_bigquery_dataset" "backend" {
  dataset_id  = "backend"
  description = "Health Canada - DocAI Warehouse POC - Backend"
  location    = "northamerica-northeast1"
}

resource "google_bigquery_table" "documents" {
  dataset_id          = google_bigquery_dataset.backend.dataset_id
  table_id            = "documents"
  deletion_protection = false

  schema = <<EOF
[
  {
    "name": "ID",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Document ID"
  },
    {
    "name": "TEXT",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Document Text"
  }
]
EOF
}

resource "google_bigquery_table_iam_member" "documents_backend_sa" {
  project    = google_bigquery_table.documents.project
  dataset_id = google_bigquery_table.documents.dataset_id
  table_id   = google_bigquery_table.documents.table_id
  role       = "roles/bigquery.admin"
  member     = "serviceAccount:${var.backend_sa_email}"
}