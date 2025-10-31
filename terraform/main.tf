module "artifact_registry" {
  source = "GoogleCloudPlatform/artifact-registry/google"

  project_id    = "compute-cluster-476800"
  location      = "northamerica-northeast2"
  format        = "DOCKER"
  repository_id = "marrow"
}
