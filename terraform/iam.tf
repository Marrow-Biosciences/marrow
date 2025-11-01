data "google_compute_default_service_account" "default" {}

resource "google_artifact_registry_repository_iam_member" "gke_reader" {
  repository = var.repository
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}
