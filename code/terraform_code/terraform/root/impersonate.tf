provider "google" {
  alias = "tokengen"
}

provider "google" {
  alias = "impersonate"

  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email"
  ]
}


data "google_service_account_access_token" "default" {
  provider               = google.impersonate
  target_service_account = var.service_account
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email"
  ]
  lifetime = "1200s"
}

/******************************************
  Provider credential configuration
 *****************************************/
provider "google" {
  access_token = data.google_service_account_access_token.default.access_token
}

provider "google-beta" {
  access_token = data.google_service_account_access_token.default.access_token
}
