resource "google_storage_bucket" "risingwave_state" {
  name          = "marrow-risingwave-state"
  location      = var.region
  project       = var.project
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
