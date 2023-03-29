terraform {
  backend "gcs" {
    bucket = "<state-bucket-name>" #this bucket need to create manually 
  }
}
