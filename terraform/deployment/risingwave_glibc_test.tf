resource "kubernetes_deployment_v1" "risingwave_glibc_test" {
  metadata {
    name = "risingwave-glibc-test-deployment"
  }
  spec {
    replicas = 1
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
          resources {
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
            limits = {
              cpu    = "20m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2beta2" "risingwave_glibc_test" {
  metadata {
    name = "risingwave-glibc-test-hpa"
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.risingwave_glibc_test.metadata[0].name
    }
    min_replicas = 0
    max_replicas = 1
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
    behavior {
      scale_down {
        stabilization_window_seconds = 60
        policy {
          type           = "Percent"
          value          = 100
          period_seconds = 60
        }
      }
    }
  }
}
