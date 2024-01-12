terraform {
  backend "gcs" {
    bucket = "marcus-experiment-tfstate-001"
    prefix = "experiment"
  }
}
