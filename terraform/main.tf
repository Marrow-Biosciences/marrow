module "artifact_registry" {
  source        = "GoogleCloudPlatform/artifact-registry/google"
  project_id    = var.project
  location      = var.region
  format        = "DOCKER"
  repository_id = var.repository
}

module "deployment" {
  source     = "./deployment"
  project    = var.project
  region     = var.region
  repository = var.repository
}
