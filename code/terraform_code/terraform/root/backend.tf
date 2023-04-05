terraform {
  backend "gcs" {
    bucket = "<terraform-state-bucket-name>" #this bucket need to create manually 
  }
}
