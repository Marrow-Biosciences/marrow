resource "google_compute_network" "marrow" {
  name                    = "marrow-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "marrow" {
  name          = "marrow-subnet"
  network       = google_compute_network.marrow.id
  ip_cidr_range = "10.0.0.0/16"
}

resource "google_container_cluster" "marrow" {
  name                = "marrow-cluster"
  location            = var.region
  network             = google_compute_network.marrow.id
  subnetwork          = google_compute_subnetwork.marrow.id
  deletion_protection = false
  enable_autopilot    = true
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }
}
