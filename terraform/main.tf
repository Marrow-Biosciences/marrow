module "artifact_registry" {
  source        = "GoogleCloudPlatform/artifact-registry/google"
  project_id    = var.project
  location      = var.region
  format        = "DOCKER"
  repository_id = var.repository
}

module "deployment" {
  source                  = "./deployment"
  project                 = var.project
  region                  = var.region
  repository              = var.repository
  risingwave_metadata_dsn = var.risingwave_metadata_dsn
  # RisingWave uses gcs:// scheme in place of the common gs:// for Google Cloud Storage
  risingwave_state_uri = "gcs://${google_storage_bucket.risingwave_state.name}"
}
