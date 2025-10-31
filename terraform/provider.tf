terraform {
  backend "gcs" {
    bucket = "marrow-terraform-state"
  }
}
