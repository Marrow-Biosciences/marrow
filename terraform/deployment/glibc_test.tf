resource "kubernetes_deployment_v1" "risingwave_glibc_test" {
  metadata {
    name = "risingwave-glibc-test"
  }
  spec {
    selector {
      match_labels = {
        app = "risingwave-glibc-test"
      }
    }
    template {
      metadata {
        labels = {
          app = "risingwave-glibc-test"
        }
      }
      spec {
        container {
          name  = "risingwave-glibc-test-container"
          image = "${var.region}-docker.pkg.dev/${var.project}/${var.repository}/risingwave-glibc_test:latest"
        }
      }
    }
  }
}
