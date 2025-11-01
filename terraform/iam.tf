data "google_compute_default_service_account" "default" {}

# resource "google_artifact_registry_repository_iam_member" "marrow_artifact_registry_reader" {
#   repository = var.repository
#   role       = "roles/artifactregistry.reader"
#   member     = "serviceAccount:${data.google_compute_default_service_account.default.email}"
# }

resource "google_storage_bucket_iam_member" "risingwave_state_storage_user" {
  bucket = google_storage_bucket.risingwave_state.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}
