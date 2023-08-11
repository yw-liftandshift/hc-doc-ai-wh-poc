data "google_project" "project" {
}

resource "random_id" "random" {
  byte_length = 4
}