resource "kubernetes_config_map_v1" "risingwave" {
  metadata {
    name = "risingwave-config"
  }
  data = {
    "risingwave.toml" = file("${path.module}/risingwave.toml")
  }
}
