resource "kubernetes_deployment_v1" "risingwave_compactor" {
  metadata {
    name = "risingwave-compactor-deployment"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "risingwave-compactor-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "risingwave-compactor-app"
        }
      }
      spec {
        container {
          name  = "risingwave-compactor-container"
          image = "${var.region}-docker.pkg.dev/${var.project}/${var.repository}/risingwave-compactor:latest"
          args = [
            "compactor-node",
            "--listen-addr", "0.0.0.0:6660",
            "--advertise-addr", "$(POD_IP):6660",
            "--prometheus-listener-addr", "0.0.0.0:1260",
            "--meta-address", "http://${kubernetes_service_v1.risingwave_meta.metadata.name}:5690",
            "--config-path", "/risingwave.toml"
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
            container_port = 6660
            name           = "grpc"
          }
          port {
            container_port = 1260
            name           = "metrics"
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

resource "kubernetes_service_v1" "risingwave_compactor" {
  metadata {
    name = "risingwave-compactor-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.risingwave_compactor.spec[0].selector[0].match_labels.app
    }
    port {
      name        = kubernetes_deployment_v1.risingwave_compactor.spec[0].template[0].spec[0].container[0].port[0].name
      port        = kubernetes_deployment_v1.risingwave_compactor.spec[0].template[0].spec[0].container[0].port[0].container_port
      target_port = kubernetes_deployment_v1.risingwave_compactor.spec[0].template[0].spec[0].container[0].port[0].name
    }
    port {
      name        = kubernetes_deployment_v1.risingwave_compactor.spec[0].template[0].spec[0].container[0].port[1].name
      port        = kubernetes_deployment_v1.risingwave_compactor.spec[0].template[0].spec[0].container[0].port[1].container_port
      target_port = kubernetes_deployment_v1.risingwave_compactor.spec[0].template[0].spec[0].container[0].port[1].name
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "risingwave_compactor" {
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name = "risingwave-compactor-monitoring"
    }
    spec = {
      selector = {
        matchLabels = {
          app = kubernetes_deployment_v1.risingwave_compactor.spec[0].selector[0].match_labels.app
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
