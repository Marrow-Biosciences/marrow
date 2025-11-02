resource "kubernetes_deployment_v1" "risingwave_glibc_test" {
  metadata {
    name = "risingwave-glibc-test-deployment"
  }
  spec {
    selector {
      match_labels = {
        app = "risingwave-glibc-test-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "risingwave-glibc-test-app"
        }
      }
      spec {
        node_selector = {
          "cloud.google.com/compute-class" = "Scale-Out"
          "kubernetes.io/arch"             = "arm64"
        }
        container {
          name  = "risingwave-glibc-test-container"
          image = "${var.region}-docker.pkg.dev/${var.project}/${var.repository}/risingwave-glibc_test:latest"
        }
      }
    }
  }
}
