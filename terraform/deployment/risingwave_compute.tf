resource "kubernetes_deployment_v1" "risingwave_compute" {
  metadata {
    name = "risingwave-compute-deployment"
  }
  spec {
    replicas = var.risingwave_compute_deployment_min_replicas
    selector {
      match_labels = {
        app = "risingwave-compute-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "risingwave-compute-app"
        }
      }
      spec {
        node_selector = {
          "cloud.google.com/gke-spot" = "true"
        }
        toleration {
          key      = "cloud.google.com/gke-spot"
          operator = "Equal"
          value    = "true"
          effect   = "NoSchedule"
        }
        container {
          name  = "risingwave-compute-container"
          image = "${var.region}-docker.pkg.dev/${var.project}/${var.repository}/risingwave-compute:latest"
          args = [
            "compute-node",
            "--listen-addr", "0.0.0.0:5688",
            "--advertise-addr", "$(POD_IP):5688",
            "--prometheus-listener-addr", "0.0.0.0:1222",
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
            container_port = 5688
            name           = "grpc"
          }
          port {
            container_port = 1222
            name           = "metrics"
          }
          volume_mount {
            name       = "config"
            mount_path = "/risingwave.toml"
            sub_path   = "risingwave.toml"
          }
          resources {
            requests = {
              cpu    = var.risingwave_compute_container_cpu_request
              memory = var.risingwave_compute_container_memory_request
            }
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

resource "kubernetes_horizontal_pod_autoscaler_v2beta2" "risingwave_compute" {
  metadata {
    name = "risingwave-compute-hpa"
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.risingwave_compute.metadata[0].name
    }
    min_replicas = var.risingwave_compute_deployment_min_replicas
    max_replicas = var.risingwave_compute_deployment_max_replicas
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.risingwave_compute_container_cpu_request
        }
      }
    }
    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = var.risingwave_compute_container_memory_request
        }
      }
    }
    behavior {
      scale_up {
        stabilization_window_seconds = 60
        select_policy                = "Max"
        policy {
          type           = "Percent"
          value          = 100
          period_seconds = 60
        }
      }
      scale_down {
        stabilization_window_seconds = 300
        select_policy                = "Min"
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 60
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "risingwave_compute" {
  metadata {
    name = "risingwave-compute-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.risingwave_compute.spec[0].selector[0].match_labels.app
    }
    port {
      name        = kubernetes_deployment_v1.risingwave_compute.spec[0].template[0].spec[0].container[0].ports[0].name
      port        = kubernetes_deployment_v1.risingwave_compute.spec[0].template[0].spec[0].container[0].ports[0].container_port
      target_port = kubernetes_deployment_v1.risingwave_compute.spec[0].template[0].spec[0].container[0].ports[0].name
    }
    port {
      name        = kubernetes_deployment_v1.risingwave_compute.spec[0].template[0].spec[0].container[0].ports[1].name
      port        = kubernetes_deployment_v1.risingwave_compute.spec[0].template[0].spec[0].container[0].ports[1].container_port
      target_port = kubernetes_deployment_v1.risingwave_compute.spec[0].template[0].spec[0].container[0].ports[1].name
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "risingwave_compute" {
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name = "risingwave-compute-monitoring"
    }
    spec = {
      selector = {
        matchLabels = {
          app = kubernetes_deployment_v1.risingwave_compute.spec[0].selector[0].match_labels.app
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
