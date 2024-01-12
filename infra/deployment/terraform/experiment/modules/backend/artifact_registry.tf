locals {
  backend_directory  = "${path.module}/../../../../../../backend"
  backend_repository = "${google_artifact_registry_repository.backend.location}-docker.pkg.dev/${google_artifact_registry_repository.backend.project}/${google_artifact_registry_repository.backend.name}"
  backend_image      = "${local.backend_repository}/backend"
}

resource "google_artifact_registry_repository" "backend" {
  location      = "northamerica-northeast1"
  repository_id = "backend-docker-repo"
  format        = "DOCKER"
}

resource "docker_image" "backend" {
  name = local.backend_image
  build {
    context = local.backend_directory
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.backend_directory, "**") : filesha1("${local.backend_directory}/${f}")]))
  }
}

resource "docker_registry_image" "backend" {
  name = docker_image.backend.name

  triggers = {
    docker_image_repo_digest = docker_image.backend.repo_digest
  }
}

resource "google_artifact_registry_repository_iam_member" "backend_repository_backend_sa" {
  location   = google_artifact_registry_repository.backend.location
  repository = google_artifact_registry_repository.backend.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.backend_sa_email}"
}