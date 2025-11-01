variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "repository" {
  type = string
}

variable "risingwave_compute_container_target_cpu" {
  type    = number
  default = 70
}

variable "risingwave_compute_container_target_memory" {
  type    = number
  default = 80
}

variable "risingwave_compute_container_cpu_request" {
  type    = string
  default = "2"
}

variable "risingwave_compute_container_memory_request" {
  type    = string
  default = "8Gi"
}

variable "risingwave_compute_deployment_min_replicas" {
  type    = number
  default = 1
}

variable "risingwave_compute_deployment_max_replicas" {
  type    = number
  default = 5
}

variable "risingwave_metadata_dsn" {
  type      = string
  sensitive = true
}

variable "risingwave_state_uri" {
  type = string
}
