output "project_id" {
  value = data.google_project.project.project_id
}

output "project_number" {
  value = data.google_project.project.number
}

output "tfstate_bucket" {
  value = google_storage_bucket.tfstate.name
}