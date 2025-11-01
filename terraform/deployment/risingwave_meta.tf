resource "kubernetes_deployment_v1" "risingwave_meta" {
  metadata {
    name = "risingwave-meta-deployment"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "risingwave-meta-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "risingwave-meta-app"
        }
      }
      spec {
        container {
          name  = "risingwave-meta-container"
          image = "${var.region}-docker.pkg.dev/${var.project}/${var.repository}/risingwave-meta:latest"
          args = [
            "--listen-addr", "0.0.0.0:5690",
            "--advertise-addr", "${kubernetes_service_v1.risingwave_meta.metadata.name}:5690",
            "--dashboard-host", "0.0.0.0:5691",
            "--prometheus-host", "0.0.0.0:1250",
            "--backend", "sql",
            "--sql-endpoint", var.risingwave_metadata_dsn,
            "--state-store", "hummock+${var.risingwave_state_uri}",
            "--data-directory", "hummock_001",
            "--config-path", "/risingwave.toml"
          ]
          env {
            name  = "RUST_BACKTRACE"
            value = "full"
          }
          port {
            container_port = 5690
            name           = "grpc"
          }
          port {
            container_port = 1250
            name           = "metrics"
          }
          port {
            container_port = 5691
            name           = "dashboard"
          }
          volume_mount {
            name       = "config"
            mount_path = "/risingwave.toml"
            sub_path   = "risingwave.toml"
          }
          readiness_probe {
            tcp_socket {
              port = "grpc"
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
          liveness_probe {
            tcp_socket {
              port = "grpc"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.risingwave.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "risingwave_meta" {
  metadata {
    name = "risingwave-meta-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.risingwave_meta.spec[0].selector[0].match_labels.app
    }
    port {
      name        = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[0].name
      port        = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[0].container_port
      target_port = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[0].name
    }
    port {
      name        = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[1].name
      port        = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[1].container_port
      target_port = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[1].name
    }
    port {
      name        = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[2].name
      port        = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[2].container_port
      target_port = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[2].name
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service_v1" "risingwave_dashboard" {
  metadata {
    name = "risingwave-dashboard"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.risingwave_meta.spec[0].selector[0].match_labels.app
    }
    port {
      name        = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[2].name
      port        = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[2].container_port
      target_port = kubernetes_deployment_v1.risingwave_meta.spec[0].template.spec.containers[0].ports[2].name
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_manifest_v1" "risingwave_meta" {
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name = "risingwave-meta-monitoring"
    }
    spec = {
      selector = {
        matchLabels = {
          app = kubernetes_deployment_v1.risingwave_meta.spec[0].selector[0].match_labels.app
        }
      }
      endpoints = [
        {
          port     = "metrics"
          interval = "15s"
        }
      ]
    }
  }
}
