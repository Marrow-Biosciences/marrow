resource "kubernetes_deployment_v1" "risingwave_frontend" {
  metadata {
    name = "risingwave-frontend-deployment"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "risingwave-frontend-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "risingwave-frontend-app"
        }
      }
      spec {
        container {
          name  = "risingwave-frontend-container"
          image = "${var.region}-docker.pkg.dev/${var.project}/${var.repository}/risingwave-frontend:latest"
          args = [
            "frontend-node",
            "--listen-addr", "0.0.0.0:4566",
            "--meta-addr", "http://${kubernetes_service_v1.risingwave_meta.metadata.name}:5690",
            "--advertise-addr", "$(POD_IP):4566",
            "--config-path", "/risingwave.toml",
            "--prometheus-listener-addr", "0.0.0.0:2222"
          ]
          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
          env {
            name  = "RUST_BACKTRACE"
            value = "full"
          }
          port {
            container_port = 4566
            name           = "sql"
          }
          port {
            container_port = 2222
            name           = "metrics"
          }
          volume_mount {
            name       = "config"
            mount_path = "/risingwave.toml"
            sub_path   = "risingwave.toml"
          }
          readiness_probe {
            tcp_socket {
              port = "sql"
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
          liveness_probe {
            tcp_socket {
              port = "sql"
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

resource "kubernetes_service_v1" "risingwave_frontend" {
  metadata {
    name = "risingwave-frontend-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.risingwave_frontend.spec[0].selector[0].match_labels.app
    }
    port {
      name        = kubernetes_deployment_v1.risingwave_frontend.spec[0].template[0].spec[0].container[0].port[0].name
      port        = kubernetes_deployment_v1.risingwave_frontend.spec[0].template[0].spec[0].container[0].port[0].container_port
      target_port = kubernetes_deployment_v1.risingwave_frontend.spec[0].template[0].spec[0].container[0].port[0].name
    }
    port {
      name        = kubernetes_deployment_v1.risingwave_frontend.spec[0].template[0].spec[0].container[0].port[1].name
      port        = kubernetes_deployment_v1.risingwave_frontend.spec[0].template[0].spec[0].container[0].port[1].container_port
      target_port = kubernetes_deployment_v1.risingwave_frontend.spec[0].template[0].spec[0].container[0].port[1].name
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_manifest_v1" "risingwave_frontend" {
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name = "risingwave-frontend-monitoring"
    }
    spec = {
      selector = {
        matchLabels = {
          app = kubernetes_deployment_v1.risingwave_frontend.spec[0].selector[0].match_labels.app
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
