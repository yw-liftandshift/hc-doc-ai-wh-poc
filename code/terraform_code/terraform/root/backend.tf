terraform {
  backend "gcs" {
    bucket = "<bucket-name>" #this bucket need to create manually 
  }
}
