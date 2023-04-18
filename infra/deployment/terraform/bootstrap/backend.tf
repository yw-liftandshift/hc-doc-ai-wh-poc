terraform {
  backend "gcs" {
    bucket = "terribly-lively-tender-lacewing"
    prefix = "bootstrap"
  }
}
