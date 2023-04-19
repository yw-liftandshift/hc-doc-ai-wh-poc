output "project_id" {
  value = google_project.project.project_id
}

output "project_number" {
  value = google_project.project.number
}

output "tfstate_bucket" {
  value = google_storage_bucket.tfstate.name
}