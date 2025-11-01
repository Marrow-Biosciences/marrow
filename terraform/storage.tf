resource "google_storage_bucket" "risingwave_state" {
  name     = "marrow-risingwave-state"
  location = var.region
  project  = var.project
}
