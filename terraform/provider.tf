terraform {
  backend "gcs" {
    bucket = "marrow-terraform-state"
  }
}

provider "google" {
  project = var.project
  region  = var.region
}
